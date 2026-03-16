# Tutorial to make a dataset for a comparative phylogenetic analysis

## Introduction

The aim of this tutorial is to provide the knowledge required to create a dataset for phylogenetic comparative analyses.

The first two steps involve databases and/or litterature. One has to find a way to download a traits dataset and a phylogenetic tree that contain the information that we are looking for. This data can exist in different formats, so one will need to standardise it.  
Then, as a third step one will need to map trait data onto the tree, creating a dataset that can be used for further analysis and visualisation.  
A bonus step will be to make visualisation of the mapped traits on the tree.

## Steps

### 1 Traits database

- Find a database containing the traits you are interested in.  
Download the table, directly on their web-portal, using their API or a dedicated R package.  
Depending on the format that you get, you might want to prune the dataset to only the variables you are interested in and put all relevant data into a single dataframe/tibble.

> Don't forget to download a table containing the traits but also a way to **identify the species** (e.g. scientific names, database codes).

- Check for missing data and remove all empty lines.

### 2 Phylogenetic trees

In R, phylogenetic trees come in objects called *phylo*. This type of object is a list containing:
1. `phylo$edge` contains a matrix of 2 columns containing numbers. Numbers represent a tip a node of the tree. On each row of this matrix, the left number is the parent node and the right number is the child node/tip. All connections (= branches) of the tree are specified in there.
2. `phylo$edge.length` contains a vector of the same length that the edge matrix. Each value is the length of the corresponding branch in the edge matrix.
3. `phylo$tip.label` contains a vector with the names of the tips (species names).

- Download a tree either in a database or using a R package. You might get different formats depending on the source, you can then transform it into the *phylo* format using an appropriate function. For example, *hclust* objects can be transformed into *phylo* objects with the `as.phylo` command from package `ape`.

- Species names in trees are generally written *Genus_species*, while there are generally written *Genus species* in databases. You can quickly modify the tree species list.
``` 
phy$tip.label <- gsub("_", " ", phy$tip.label)
```

### 3 Matching the db and the tree

For the analysis to work, you need to use matching species (or other OTU) names in the database and the tree, as it will be your link between the phylogenetic data and the traits data. Several databases provide detailed taxonomic information allowing you to check synonyms, old names, etc.

> I propose two alternatives in my example, but one is failing because the WORMS database contains data for marine species only, and the methode using the fishbase package is very time-consuming.

- Pass both you db species list and you tip labels through a taxonomic database to get matching names and remove synonyms and old names.

- Prune the tree to species that match your tip labels and dp species.
```
# checks tip labels against a vector of species names
checked_names <- geiger::name.check(phy, data.names = db$species)

# uses the information of checked_names to prune the tree
newphy <- ape::drop.tip(phy, checked_names$tree_not_data)
```

- Reorder the db to the same order of the tree so that species names and tip labels match.
```
db <- filter(db, pecies %in% newphy$tip.label)
db <- db[match(newphy$tip.label, db$species), ]
```

### 4 Visualise the trait onto the phylogeny

- Extract the variable (trait) that you are interested in into a vector and put the species names as the names of this vector.
```
traitvector <- db$trait
names(traitvector) <- db$species
```

- Build a coloured phylogenetic tree where colour is dependent on the value of the (continuous) trait. Save it in a PDF (vectorised format).
```
pdf(file = "contMap_plot.pdf", width = 35, height = 35) # set dimensions
contMap(
  brainphy,
  brainvector,
  type = "fan",
  fsize = c(0.7, 1.1),
  outline = FALSE
)
dev.off() 
```