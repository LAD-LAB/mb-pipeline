# mb-pipeline

Code for analyzing metabarcoding (FoodSeq) datasets in the [David Lab](https://sites.duke.edu/davidlab/) at Duke University. For full documentation, see the [FoodSeq Handbook](https://lad-lab.github.io/).

## Repository Structure

```
mb-pipeline/
├── pipeline/          # Cluster scripts and R notebook for creating phyloseq objects
├── reference/         # Reference databases and samplesheet templates
└── foodseq-protocols/ # Wet lab protocols
```

## Getting Started

1. Clone this repository to your HPC cluster
2. Install the [`foodseq.tools`](https://github.com/Ashish-Subramanian/foodseq.tools) R package
3. Follow the instructions in [`pipeline/`](pipeline/) or the [FoodSeq Handbook](https://lad-lab.github.io/pipeline.html)
