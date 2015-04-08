
[![Build Status](https://travis-ci.org/ropensci/rDat.svg)](https://travis-ci.org/ropensci/rDat)

# rDat
![dat](http://i.imgur.com/1iD2dEx.png)

_Software is pre-alpha. Not yet ready for testing or use with real world data_

rDat provides a programmatic interface to the [Dat project](https://github.com/maxogden/) (v `5.0.5`). The package makes data syncable and allows for automatic sync and updates of data sets

## Installation instructions

If you have not already installed `dat`, follow instructions here:

```
npm install dat -g
```

[More detailed instructions](https://github.com/maxogden/dat#install)

Then install the R package:

```r
library(devtools)
install_github("ropensci/rDat")
```

[![ropensci footer](http://ropensci.org/public_images/github_footer.png)](http://ropensci.org)


## API
This api is experimental and hasn't been finalized or implemented. Stay tuned for updates

#### init
```
dat = rDat.init()
```
Inits a dat in the current working directory

#### rDat.clone
```
dat = rDat.clone('ssh://path/to/dat')
```
Gets someone else's dat

#### rDat.checkout
```
checkout(dat, hash)
```
Gets the dat at a particular hash. Adds the dataframe to a dat

#### rDat.push
```
push(dat)
```
Pushes the data we've added to dat to peers

#### rDat.pull
```
pull(dat)
```
Syncs the changes of other peers to the local dat

#### rDat.create_dataset
```
dataset = get_dataset(dat, dataset_name)
```
Create a dataset with the given name in the dat

#### rDat.get_dataset
```
dataset = get_dataset(dat, dataset_name)
```
Get an rDat.dataset

## rDat.dataset

#### dataset.get_rows
```
dataframe = get_rows(dataset)
```
Gets an entire table as a R.dataframe

#### dataset.add_rows
```
add_rows(dataset, dataframe)
```
Add the dataframe to the dataset. This could create conflicts in the dat, but you don't have to worry about those yet.

#### dataset.get_row
```
row = get_row(dataset, key)
```
Gets a row from the dat with the particular key

#### dataset.add_file
```
add_file(dataset, name, dataframe)
```
Add a file to the dataset with a given name

#### dataset.get_file
```
get_file(dataset, name, output_file)
```
Gets the file that's in the dataset with a given name to an output file (how is this defined?)

