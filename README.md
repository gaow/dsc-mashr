# dsc-mashr

DSC for mashr related investigations

## Examples

To view what is available,

```
./est_v.dsc -h
```

To run a simple toy example just to check everything works (for debug purpose):

```
$ ./est_v.dsc --target toy --truncate -c 4

INFO: Load command line DSC sequence: toy
INFO: DSC script exported to est_v.html
INFO: Constructing DSC from ./est_v.dsc ...
INFO: Building execution graph & running DSC ...
[###########################################] 43 steps processed (43 jobs completed)
INFO: Building DSC database ...
INFO: DSC complete!
INFO: Elapsed time 17.367 seconds.
```
where `-c 4` use 4 CPU cores.

To make query of quantities of interest,

```r
library(dscrutils)
# Scores can be directly compared. `aggregate` function is recommanded
dscquery('est_v', targets="simulate_toy estimate.DSC_TIME summary summary.score")
# ROC results are in files that one has to manually extract and plot using `readRDS()`, 
# or, `dscrutils::read_dsc` which additionally allows loading results from Python modules.
dscquery('est_v', targets="simulate_toy estimate ROC")
```

To run the complete analysis,

```
$ ./est_v.dsc --target default -c 4
```

The complete analysis might take some time to run.

## Run on RCC midway

Edit the file `config.yaml` to specify resource usage, then on `midway`:


```
$ ./est_v.dsc --target default -c 4 --host config.yaml
```
