output "shared_image_gallery" {
  description = "Azure Shared Image Gallery output object"
  value       = azurerm_shared_image_gallery.shared_image_gallery
}

output "id" {
  description = "Azure Shared Image Gallery ID"
  value       = azurerm_shared_image_gallery.shared_image_gallery.id
}

output "name" {
  description = "Azure Shared Image Gallery name"
  value       = azurerm_shared_image_gallery.shared_image_gallery.name
}

output "shared_images_definitions" {
  description = "Azure Shared Images definitions"
  value       = azurerm_shared_image.shared_image
}
