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

output "sa_email" {
  value = google_service_account.ia_packaged_sa.email
  description = "SA"
}

output "artifact_repo_name" {
  value = google_artifact_registry_repository.images.name
  description = "SA"
}

output "bucket_tf_state_name" {
  value       = google_storage_bucket.tf_state_bucket.name
  description = "TF State Bucket"
}

output "firebase_api_key" {
  value = data.external.api_key.result.keyString
  description = "Firebase API Key"
}

