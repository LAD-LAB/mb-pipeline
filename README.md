# mb-pipeline

Code for analyzing metabarcoding (FoodSeq) datasets in the [David Lab](https://sites.duke.edu/davidlab/) at Duke University. For full documentation, see the [FoodSeq Handbook](https://lad-lab.github.io/).

## Repository Structure

```
mb-pipeline/
├── pipeline/          # Cluster scripts and R notebook for creating phyloseq objects
├── anonymizer/        # Human read anonymizer for SRA submission
├── templates/         # Samplesheet and sample metadata templates
└── foodseq-protocols/ # Wet lab protocols
```

Reference databases and common names CSVs are maintained in [`food-dbs`](https://github.com/LAD-LAB/food-dbs).

## Getting Started

1. Clone this repository to your HPC cluster
2. Install the [`foodseq.tools`](https://github.com/Ashish-Subramanian/foodseq.tools) R package
3. Follow the instructions in [`pipeline/`](pipeline/) or the [FoodSeq Handbook](https://lad-lab.github.io/pipeline.html)
