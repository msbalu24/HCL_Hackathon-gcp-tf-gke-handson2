package main

import rego.v1

# 1. Enforce Private GKE Nodes
deny contains msg if {
	some rc in input.resource_changes
	rc.type == "google_container_cluster"
	rc.change.after.private_cluster_config[0].enable_private_nodes != true
	msg := sprintf("SECURITY VIOLATION: GKE cluster '%s' must enable private nodes.", [rc.address])
}

# 2. Enforce Workload Identity on GKE Cluster
deny contains msg if {
	some rc in input.resource_changes
	rc.type == "google_container_cluster"
	count(rc.change.after.workload_identity_config) == 0
	msg := sprintf("SECURITY VIOLATION: GKE cluster '%s' must configure Workload Identity.", [rc.address])
}

# 3. Enforce Uniform Bucket-Level Access on GCS Buckets
deny contains msg if {
	some rc in input.resource_changes
	rc.type == "google_storage_bucket"
	rc.change.after.uniform_bucket_level_access != true
	msg := sprintf("SECURITY VIOLATION: GCS bucket '%s' must enable uniform_bucket_level_access.", [rc.address])
}

# 4. Enforce Shielded Instance Secure Boot on GKE Node Pools
deny contains msg if {
	some rc in input.resource_changes
	rc.type == "google_container_node_pool"
	rc.change.after.node_config[0].shielded_instance_config[0].enable_secure_boot != true
	msg := sprintf("SECURITY VIOLATION: GKE node pool '%s' must enable Shielded VM Secure Boot.", [rc.address])
}
