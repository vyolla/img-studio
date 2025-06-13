# /**
#  * Copyright 2023 Google LLC
#  *
#  * Licensed under the Apache License, Version 2.0 (the "License");
#  * you may not use this file except in compliance with the License.
#  * You may obtain a copy of the License at
#  *
#  *      http://www.apache.org/licenses/LICENSE-2.0
#  *
#  * Unless required by applicable law or agreed to in writing, software
#  * distributed under the License is distributed on an "AS IS" BASIS,
#  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  * See the License for the specific language governing permissions and
#  * limitations under the License.
#  */

locals {
  imgstudio_output      = "${var.project_id}-imgstudio-output"
  imgstudio_library     = "${var.project_id}-imgstudio-library"
  imgstudio_export_cfg  = "${var.project_id}-imgstudio-export-cfg"
  run_service_name      = "img-studio"
  image_name            = "${var.region}-docker.pkg.dev/${var.project_id}/${var.artifact_repo_name}/imgstudio:latest"
  run_env_vars = {
        NEXT_PUBLIC_PROJECT_ID          = var.project_id
        NEXT_PUBLIC_VERTEX_API_LOCATION = var.region
        NEXT_PUBLIC_GCS_BUCKET_LOCATION = var.region
        NEXT_PUBLIC_GEMINI_MODEL        = var.model_name
        NEXT_PUBLIC_SEG_MODEL           = var.model_name
        NEXT_PUBLIC_EDIT_ENABLED        = true
        NEXT_PUBLIC_VEO_ENABLED         = true
        NEXT_PUBLIC_VEO_ITV_ENABLED     = true
        NEXT_PUBLIC_VEO_ADVANCED_ENABLED= true
        NEXT_PUBLIC_PRINCIPAL_TO_USER_FILTERS = ""
        NEXT_PUBLIC_OUTPUT_BUCKET       = local.imgstudio_output
        NEXT_PUBLIC_TEAM_BUCKET         = local.imgstudio_library
        NEXT_PUBLIC_EXPORT_FIELDS_OPTIONS_URI = google_storage_bucket_object.export_cfg_file.name
        NEXT_PUBLIC_FIREBASE_API_KEY    = var.api_key
        NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN= "${var.project_id}.firebaseapp.com"
        NEXT_PUBLIC_FIREBASE_PROJECT_ID = var.project_id
        NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET= "${var.project_id}.appspot.com"
        NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID= ""
        NEXT_PUBLIC_FIREBASE_APP_ID     = ""
  }
}

resource "google_storage_bucket" "output" {
  project                     = var.project_id
  name                        = local.imgstudio_output
  location                    = var.region
  force_destroy               = true
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "library" {
  project                     = var.project_id
  name                        = local.imgstudio_library
  location                    = var.region
  force_destroy               = true
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "export_cfg" {
  project                     = var.project_id
  name                        = local.imgstudio_export_cfg
  location                    = var.region
  force_destroy               = true
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_object" "export_cfg_file" {
  name   = "export-fields-options.json"
  bucket = google_storage_bucket.export_cfg.name
  source = "${path.module}/source/export-fields-options.json"
  depends_on = [
    google_storage_bucket.export_cfg
  ]
}

resource "local_file" "cloud_build" {
  content  = <<-EOF
  steps:
    - name: 'gcr.io/cloud-builders/docker'
      args:
        [
          'build',
          '-t',
          '${local.image_name}',
          '--build-arg',
          '_NEXT_PUBLIC_PROJECT_ID=${var.project_id}',
          '--build-arg',
          '_NEXT_PUBLIC_VERTEX_API_LOCATION=${var.region}',
          '--build-arg',
          '_NEXT_PUBLIC_GCS_BUCKET_LOCATION=${var.region}',
          '--build-arg',
          '_NEXT_PUBLIC_GEMINI_MODEL=${var.model_name}',
          '--build-arg',
          '_NEXT_PUBLIC_SEG_MODEL=${var.model_name}',
          '--build-arg',
          '_NEXT_PUBLIC_EDIT_ENABLED=true',
          '--build-arg',
          '_NEXT_PUBLIC_VEO_ENABLED=true',
          '--build-arg',
          '_NEXT_PUBLIC_VEO_ITV_ENABLED=true',
          '--build-arg',
          '_NEXT_PUBLIC_VEO_ADVANCED_ENABLED=true',
          '--build-arg',
          '_NEXT_PUBLIC_PRINCIPAL_TO_USER_FILTERS=',
          '--build-arg',
          '_NEXT_PUBLIC_OUTPUT_BUCKET=${local.imgstudio_output}',
          '--build-arg',
          '_NEXT_PUBLIC_TEAM_BUCKET=${local.imgstudio_library}',
          '--build-arg',
          '_NEXT_PUBLIC_EXPORT_FIELDS_OPTIONS_URI=gs://${google_storage_bucket.export_cfg.name}/${google_storage_bucket_object.export_cfg_file.name}',
          '--build-arg',
          '_NEXT_PUBLIC_FIREBASE_API_KEY=${var.api_key}',
          '--build-arg',
          '_NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=${var.project_id}.firebaseapp.com',
          '--build-arg',
          '_NEXT_PUBLIC_FIREBASE_PROJECT_ID=${var.project_id}',
          '--build-arg',
          '_NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=${var.project_id}.appspot.com',
          '--build-arg',
          '_NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=',
          '--build-arg',
          '_NEXT_PUBLIC_FIREBASE_APP_ID=',
          '.',
        ]

      # script: |
      #   docker build -t ${local.image_name} .
      # automapSubstitutions: true
  images:
  - '${local.image_name}'
  EOF
  filename = "${path.module}/source/cloudbuild.yaml"
}


resource "null_resource" "build_image" {
  triggers = {
    redeployment = data.archive_file.run_staging.output_md5
  }

  provisioner "local-exec" {
    command = "cd modules/img-studio/source && gcloud builds submit --region=${var.region} --project=${var.project_id} --config cloudbuild.yaml"
  }
    depends_on = [local_file.cloud_build]
}

data "archive_file" "run_staging" {
  type        = "zip"
  source_dir  = abspath("${path.module}/source")
  output_path = abspath("${path.module}/.tmp/source.zip")
  excludes = [
    "node_modules",
    ".next",
    "third_party",
    "env",
  ]
}

resource "google_cloud_run_v2_service" "img_studio" {
  project  = var.project_id
  name     = local.run_service_name
  location = var.region
  ingress = "INGRESS_TRAFFIC_ALL"

  template {
    service_account = var.sa_email
    execution_environment = "EXECUTION_ENVIRONMENT_GEN2"
    scaling {
      min_instance_count = 0
      max_instance_count = 1
    }

    containers {
      image = local.image_name
      resources {
        limits = {
          cpu    = "2"
          memory = "4096Mi"
        }
      }
      dynamic "env" {
          for_each = local.run_env_vars
          content {
            name  = env.key
            value = env.value
          }
        }      
    }
  }

  depends_on = [
    null_resource.build_image
  ]
}

resource "google_cloud_run_service_iam_member" "run" {
  project = var.project_id
  location = google_cloud_run_v2_service.img_studio.location
  service  = google_cloud_run_v2_service.img_studio.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

## Firestore

resource "google_firestore_database" "database" {
  project     = var.project_id
  name        = "(default)"
  location_id = var.region
  type        = "FIRESTORE_NATIVE"

  delete_protection_state = "DELETE_PROTECTION_ENABLED"
}

resource "google_firestore_index" "metadata_composite_index" {
  project     = var.project_id
  database    = google_firestore_database.database.name
  collection  = "metadata"
  query_scope = "COLLECTION"

  fields {
    field_path   = "combinedFilters"
    array_config = "CONTAINS"
  }

  fields {
    field_path = "timestamp"
    order      = "DESCENDING"
  }

  fields {
    field_path = "__name__"
    order      = "DESCENDING"
  }
}

resource "google_firebaserules_release" "primary" {
  name         = "cloud.firestore"
  project      = var.project_id
  ruleset_name = "projects/${var.project_id}/rulesets/${google_firebaserules_ruleset.firestore_rules.name}"
  depends_on = [
    google_firestore_database.database,
    google_firebaserules_ruleset.firestore_rules
  ]
}

resource "google_firebaserules_ruleset" "firestore_rules" {
  project  = var.project_id
  source {
    files {
      content = templatefile("${path.module}/firestore.rules", {
        service_account_email = var.sa_email
      })
      name = "firestore.rules"
    }
    
  }
}