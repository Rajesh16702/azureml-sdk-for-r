# Copyright(c) Microsoft Corporation.
# Licensed under the MIT license.

library(azuremlsdk)
library(foreach)

# needed to load register_do_azureml_parallel() method.
# this won't be required when register_do_azureml_parallel() method is public.
devtools::load_all()

ws <- load_workspace_from_config()
amlcluster <- get_compute(ws, "r-cluster")

# call this method to register foreach backend with Workspace and AmlCompute cluster on which
# parallel job would run.
register_do_azureml_parallel(ws, amlcluster)

model <- readRDS("model.rds")

data <- read.csv("iris.csv")
nRows <- nrow(data)

result <- foreach(i = 1:nRows,
                  .packages = "jsonlite",
                  node_count = 3L,
                  process_count_per_node = 2L,
                  experiment_name = "iris_inferencing",
                  job_timeout = 3600) %dopar% {

                 prediction <- predict(model, data[i, ])
                 result <- as.character(prediction)
                 toJSON(result)
}
