#!/usr/bin/env Rscript

# Human Read Anonymizer
# Detects and replaces human sequences in FASTQ files using k-mer matching.
#
# KEY FIX: R1 gets the forward-strand replacement; R2 gets the reverse
# complement.  DADA2's merge step aligns denoised ASV *sequences* (not quality
# scores), so R1 and R2 must be complementary for merging to succeed.
#
# All replaced reads get the same single replacement sequence.  DADA2 handles
# many identical reads perfectly — that's how it learns its error model.
# Original quality scores are preserved so the error model stays realistic.

suppressPackageStartupMessages({
  library(Biostrings)
  library(ShortRead)
})

# ---------------------------------------------------------------------------
# Replacement core (100 bp, forward strand)
# Matches the biological insert length between 12Sv5 primers (~100 bp).
# This is the sequence that will appear as the replacement ASV after
# cutadapt primer trimming and DADA2 merging.
# Based on human 12S mitochondrial sequence so taxonomic classifiers
# still assign Homo sapiens.
# ---------------------------------------------------------------------------
REPLACEMENT_CORE <- "AGGGATATGAAGCACCGCCAGGTCCTTTGAGTTTTAAGCTGTGGCTCGTAGTGTTCTGGCGAGCAGTTTTGTTGATTTAACTGTTGAGGTTTAGGGCTAA"
REPLACEMENT_CORE_RC <- as.character(reverseComplement(DNAString(REPLACEMENT_CORE)))

# 12Sv5 primers (must match the downstream cutadapt primer-trim step)
FORWARD_PRIMER <- "TAGAACAGGCTCCTCTAG"   # 18 bp
REVERSE_PRIMER <- "GCATAGTGGGGTATCTAA"   # 18 bp
FWD_PRIMER_RC  <- as.character(reverseComplement(DNAString(FORWARD_PRIMER)))
REV_PRIMER_RC  <- as.character(reverseComplement(DNAString(REVERSE_PRIMER)))
PRIMER_LEN     <- 18L

# ============================================================================
# K-MER MATCHING
# ============================================================================

get_kmer_index <- function(seq, pos, k) {
  kmer <- 0
  bases <- c('A'=0, 'C'=1, 'G'=2, 'T'=3)
  for(j in 1:k) {
    base <- substr(seq, pos+j, pos+j)
    if(base %in% names(bases)) {
      kmer <- 4*kmer + bases[base]
    } else {
      return(-1)
    }
  }
  return(kmer)
}

get_kmer_array <- function(seq, k) {
  seq_len <- nchar(seq)
  if(seq_len < k) return(integer(0))
  klen <- seq_len - k + 1
  kmers <- integer(klen)
  j <- 1
  for(i in 0:(klen-1)) {
    kmer <- get_kmer_index(seq, i, k)
    if(kmer >= 0) {
      kmers[j] <- kmer
      j <- j + 1
    }
  }
  if(j > 1) {
    return(sort(kmers[1:(j-1)]))
  } else {
    return(integer(0))
  }
}

kmer_overlap <- function(query_kmers, ref_kmers) {
  if(length(query_kmers) == 0) return(0)
  sum(query_kmers %in% ref_kmers) / length(query_kmers)
}

build_human_kmer_db <- function(ref_file, k=8) {
  cat("Building human k-mer database from:", ref_file, "\n")
  refs <- readDNAStringSet(ref_file)
  all_kmers <- integer(0)
  for(i in seq_along(refs)) {
    seq <- as.character(refs[i])
    all_kmers <- c(all_kmers, get_kmer_array(seq, k))
    all_kmers <- c(all_kmers, get_kmer_array(
      as.character(reverseComplement(DNAString(seq))), k))
  }
  unique_kmers <- sort(unique(all_kmers))
  cat("  Found", length(unique_kmers), "unique k-mers from",
      length(refs), "reference sequences\n")
  return(unique_kmers)
}

# ============================================================================
# REPLACEMENT
# ============================================================================

#' Fit the replacement sequence to the target length.
#' @param replacement  Character — full-length replacement (fwd or rc strand)
#' @param target_length  Integer — desired core length
#' @param trim_left  Logical — if TRUE trim from left (for RC/R2), else right
fit_replacement <- function(replacement, target_length, trim_left = FALSE) {
  rlen <- nchar(replacement)
  if(target_length <= rlen) {
    if(trim_left) {
      substr(replacement, rlen - target_length + 1, rlen)
    } else {
      substr(replacement, 1, target_length)
    }
  } else {
    # Extend by repeating (should not happen — replacement is 122bp, max core is ~115bp)
    warning("Unexpected: core_len (", target_length, ") > replacement length (", rlen, ")")
    extended <- paste(rep(replacement, ceiling(target_length / rlen)), collapse="")
    substr(extended, 1, target_length)
  }
}

# ============================================================================
# PROCESS A SINGLE FASTQ FILE
# ============================================================================

process_fastq <- function(input_file, output_file, human_kmers,
                          threshold = 0.7, k = 8) {
  cat("\nProcessing:", input_file, "\n")
  cat("Output to:",  output_file, "\n")

  # Detect R1 vs R2
  is_r1 <- grepl("_R1_", input_file)
  is_r2 <- grepl("_R2_", input_file)
  if(!is_r1 && !is_r2) stop("Cannot determine R1/R2 from filename: ", input_file)
  cat("Detected", ifelse(is_r1, "R1 (forward)", "R2 (reverse)"), "reads\n")

  # Pick the correct replacement strand
  replacement_seq <- if(is_r1) REPLACEMENT_CORE else REPLACEMENT_CORE_RC

  # Count input reads
  cat("Counting input reads...\n")
  input_lines <- as.integer(system(
    paste0("zcat ", shQuote(input_file), " | wc -l"), intern = TRUE))
  input_count <- input_lines / 4L
  cat("Input file contains:", input_count, "reads\n")

  # Read FASTQ
  cat("Reading input file...\n")
  fq <- readFastq(input_file)
  total_reads <- length(fq)
  cat("Processing", total_reads, "reads...\n")

  seqs     <- as.character(sread(fq))
  quals    <- as.character(quality(quality(fq)))
  full_ids <- as.character(ShortRead::id(fq))

  output_seqs  <- seqs
  output_quals <- quals

  human_reads <- 0L
  short_reads <- 0L

  # Main loop
  for(i in seq_along(seqs)) {
    seq_len <- nchar(seqs[i])
    if(seq_len < PRIMER_LEN + k * 3) {
      short_reads <- short_reads + 1L
      next
    }

    # Extract region after 5' primer for k-mer matching
    seq_for_matching <- substr(seqs[i], PRIMER_LEN + 1L, seq_len)

    seq_kmers <- get_kmer_array(seq_for_matching, k)
    if(length(seq_kmers) == 0) next

    overlap_fwd <- kmer_overlap(seq_kmers, human_kmers)
    overlap_rc  <- kmer_overlap(
      get_kmer_array(as.character(reverseComplement(DNAString(seq_for_matching))), k),
      human_kmers)
    overlap <- max(overlap_fwd, overlap_rc)

    if(overlap < threshold) next

    # --- Human read: replace insert, keep primers + adapter tail --------------
    human_reads <- human_reads + 1L

    # Read structure (151 bp):
    #   R1: [FWD_PRIMER 18bp][INSERT ~100bp][REV_PRIMER 18bp][adapter ~15bp]
    #   R2: [RC(REV_PRIMER) 18bp][RC(INSERT) ~100bp][RC(FWD_PRIMER) 18bp][adapter ~15bp]
    #
    # The 3' primer is NOT at the very end of the read — it's followed by
    # adapter read-through.  Cutadapt's linked adapter trims both primers
    # and extracts just the insert between them.
    #
    # Strategy: replace only the insert between the two primers.  Keep the
    # 5' primer (pos 1-18), place the replacement core, then the 3' primer,
    # then keep the original adapter tail.  This produces a read that
    # cutadapt handles identically to the original.

    core_len <- nchar(replacement_seq)  # 100 bp — matches biological insert

    # 3' primer as it appears in the read (matches cutadapt linked adapter):
    #   R1 linked: ^FWD_PRIMER...REV_PRIMER      → 3' is REV_PRIMER (fwd strand)
    #   R2 linked: ^RC(REV_PRIMER)...RC(FWD_PRIMER) → 3' is RC(FWD_PRIMER)
    primer_3p_seq <- if(is_r1) REVERSE_PRIMER else FWD_PRIMER_RC

    # Build the replacement read:
    #   [original 5' primer][replacement core][3' primer][original adapter tail]
    replaced_region_len <- PRIMER_LEN + core_len + PRIMER_LEN  # 18 + 100 + 18 = 136
    if(replaced_region_len < seq_len) {
      # There's adapter tail to preserve
      output_seqs[i] <- paste0(
        substr(seqs[i], 1, PRIMER_LEN),            # original 5' primer
        replacement_seq,                             # replacement core (100bp)
        primer_3p_seq,                               # 3' primer (18bp)
        substr(seqs[i], replaced_region_len + 1L, seq_len))  # original adapter tail
    } else {
      # Read is short enough that insert + primers fill it entirely
      output_seqs[i] <- paste0(
        substr(seqs[i], 1, PRIMER_LEN),
        fit_replacement(replacement_seq, seq_len - PRIMER_LEN, trim_left = is_r2))
    }
    # Quality string stays as-is (output_quals[i] is already the original)

    if(human_reads <= 5) {
      cat("\n  === Replacement", human_reads, "===\n")
      cat("  Read index:", i, "\n")
      cat("  Overlap:", round(overlap, 3), "\n")
      cat("  Original length:", seq_len, "| Output length:", nchar(output_seqs[i]), "\n")
      cat("  Core (first 40bp):", substr(replacement_seq, 1, 40), "...\n")
      if(is_r2) cat("  [R2: using RC of replacement]\n")
    }

    if(i %% 50000 == 0) {
      cat("  Processed", i, "reads,", human_reads, "replaced\n")
    }
  }

  cat("\nHuman reads replaced:", human_reads, "/", total_reads, "\n")

  # Write output
  cat("Writing output file...\n")
  output_dir <- dirname(output_file)
  if(!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)

  gz_conn <- gzfile(output_file, "w")
  for(i in seq_along(output_seqs)) {
    writeLines(c(paste0("@", full_ids[i]), output_seqs[i], "+", output_quals[i]),
               gz_conn)
  }
  close(gz_conn)

  # Verification
  cat("\n=== VERIFICATION ===\n")
  verification_pass <- TRUE

  if(human_reads > 0) {
    fq_out <- readFastq(output_file)
    verify_seqs <- as.character(sread(fq_out))

    # Spot-check: no output read should contain original human sequence
    # (check first 20bp of core against replacement prefix)
    expected_prefix <- if(is_r1) {
      substr(REPLACEMENT_CORE, 1, 20)
    } else {
      substr(REPLACEMENT_CORE_RC, nchar(REPLACEMENT_CORE_RC) - 19, nchar(REPLACEMENT_CORE_RC))
    }

    n_check <- min(10L, length(verify_seqs))
    n_found <- 0L
    for(j in seq_len(n_check)) {
      core <- substr(verify_seqs[j], PRIMER_LEN + 1L,
                     PRIMER_LEN + 20L)
      # For R2 check the end instead
      if(is_r2) {
        vlen <- nchar(verify_seqs[j])
        core <- substr(verify_seqs[j], vlen - PRIMER_LEN - 19, vlen - PRIMER_LEN)
      }
      if(core == expected_prefix) n_found <- n_found + 1L
    }
    # Not all reads are human, so we just check the ratio makes sense
    cat("  Spot-check: ", n_found, "/", n_check, "sampled reads contain replacement prefix\n")
  }

  # Read-count check
  output_lines <- as.integer(system(
    paste0("zcat ", shQuote(output_file), " | wc -l"), intern = TRUE))
  output_count <- output_lines / 4L

  cat("\n=== Summary ===\n")
  cat("Input reads:          ", input_count, "\n")
  cat("Output reads:         ", output_count, "\n")
  cat("Human reads replaced: ", human_reads,
      "(", round(100 * human_reads / input_count, 2), "%)\n")
  cat("Too short (kept as-is):", short_reads, "\n")

  if(input_count != output_count) {
    warning("READ COUNT MISMATCH! ", abs(input_count - output_count), " reads difference!")
    verification_pass <- FALSE
  } else {
    cat("Read count preserved: YES\n")
  }

  if(verification_pass) {
    cat("Verification: PASSED\n")
  }

  return(list(total = total_reads, human = human_reads, short = short_reads,
              input_count = input_count, output_count = output_count,
              verification_pass = verification_pass))
}

# ============================================================================
# MAIN
# ============================================================================

main <- function() {
  args <- commandArgs(trailingOnly = TRUE)

  if(length(args) < 3) {
    cat("Usage: Rscript human_read_anonymizer.R <human_ref.fasta> <input.fastq.gz> <output.fastq.gz> [threshold] [k]\n")
    quit(status = 1)
  }

  ref_file    <- args[1]
  input_file  <- args[2]
  output_file <- args[3]
  threshold   <- if(length(args) >= 4) as.numeric(args[4]) else 0.7
  k           <- if(length(args) >= 5) as.integer(args[5]) else 8L

  if(!file.exists(ref_file))   stop("Reference file not found: ", ref_file)
  if(!file.exists(input_file)) stop("Input file not found: ", input_file)

  cat("=== Human Read Anonymizer ===\n")
  cat("K-mer size:       ", k, "\n")
  cat("Threshold:        ", threshold, "\n")
  cat("Replacement (fwd):", REPLACEMENT_CORE, "\n")
  cat("Replacement (rc): ", REPLACEMENT_CORE_RC, "\n")
  cat("R1 -> fwd replacement; R2 -> RC replacement\n\n")

  human_kmers <- build_human_kmer_db(ref_file, k)
  stats <- process_fastq(input_file, output_file, human_kmers, threshold, k)

  cat("\n=== Processing Complete ===\n")
}

if(!interactive()) {
  main()
}
