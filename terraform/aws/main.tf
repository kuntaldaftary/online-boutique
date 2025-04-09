resource "null_resource" "apply_deployment" {
  provisioner "local-exec" {
    interpreter = ["bash", "-exc"]
    command     = <<EOT
      # Configure kubectl to use the EKS cluster
      aws eks update-kubeconfig --region ${var.region} --name ${module.eks_cluster.cluster_name}

      # Apply the Kubernetes manifests using Kustomize
      kubectl apply -k ${var.filepath_manifest} -n ${var.namespace}
    EOT
  }

  depends_on = [
    module.eks_cluster
  ]
}

resource "null_resource" "wait_conditions" {
  provisioner "local-exec" {
    interpreter = ["bash", "-exc"]
    command     = <<EOT
      # Wait for Kubernetes metrics API to be available
      kubectl wait --for=condition=AVAILABLE apiservice/v1beta1.metrics.k8s.io --timeout=180s

      # Wait for all pods to be ready
      kubectl wait --for=condition=ready pods --all -n ${var.namespace} --timeout=280s
    EOT
  }

  depends_on = [
    resource.null_resource.apply_deployment
  ]
}
