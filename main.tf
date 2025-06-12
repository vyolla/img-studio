
/**
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

module "project-host" {
    source          = "./modules/project"
    project_id      = var.project_id
  }
  
  module "img-studio" {
    count           = var.deploy_modules["img-studio"] ? 1 : 0
    source          = "./modules/img-studio"
    project_id      = var.project_id
    bq_dataset      = module.bqeasy.bq_dataset
    bq_table        = module.bqeasy.bq_table
    region          = var.region
    api_key         = module.project-host.firebase_api_key
    sa_email        = module.project-host.sa_email
    artifact_repo_name = module.project-host.artifact_repo_name
  
    depends_on      = [module.project-host]
  }
    
  resource "local_file" "default" {
    file_permission = "0644"
    filename        = "${path.module}/backend.tf"
  
    content = <<-EOT
    terraform {
      backend "gcs" {
        bucket = "${module.project-host.bucket_tf_state_name}"
      }
    }
    EOT
  
    depends_on      = [module.project-host]
  }
  