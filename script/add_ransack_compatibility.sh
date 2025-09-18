#!/bin/bash
# Script to add Ransack 4.0 compatibility methods to all ActiveAdmin models

echo "Adding Ransack 4.0 compatibility methods to models..."

# Check if we need to create external gem compatibility file
if [ ! -f "/Users/kumarin/Library/CloudStorage/OneDrive-BlackDuckSoftware/Desktop/openhub/ohloh-ui/config/initializers/doorkeeper_ransack_compatibility.rb" ]; then
  echo "Creating compatibility initializer for Doorkeeper models"
  cat > "/Users/kumarin/Library/CloudStorage/OneDrive-BlackDuckSoftware/Desktop/openhub/ohloh-ui/config/initializers/doorkeeper_ransack_compatibility.rb" << 'EOL'
# frozen_string_literal: true

# Add Ransack 4.0+ compatibility to Doorkeeper::Application model
# This is required because Doorkeeper is a gem and we can't directly modify its models

Rails.application.config.to_prepare do
  Doorkeeper::Application.class_eval do
    def self.ransackable_attributes(auth_object = nil)
      ["confidential", "created_at", "id", "name", "redirect_uri", "scopes", "secret", "uid", "updated_at"]
    end

    def self.ransackable_associations(auth_object = nil)
      ["access_grants", "access_tokens"]
    end
  end

  # Add compatibility for JobStatus
  JobStatus.class_eval do
    def self.ransackable_attributes(auth_object = nil)
      ["id", "name", "description", "created_at", "updated_at"]
    end

    def self.ransackable_associations(auth_object = nil)
      ["jobs"]
    end
  end

  # Add compatibility to any other Doorkeeper models used in ActiveAdmin
  Doorkeeper::AccessToken.class_eval do
    def self.ransackable_attributes(auth_object = nil)
      ["created_at", "id", "resource_owner_id", "scopes", "token", "updated_at"]
    end
    
    def self.ransackable_associations(auth_object = nil)
      ["application"]
    end
  end

  Doorkeeper::AccessGrant.class_eval do
    def self.ransackable_attributes(auth_object = nil)
      ["code", "created_at", "expires_in", "id", "redirect_uri", "resource_owner_id", "revoked_at", "scopes", "updated_at"]
    end
    
    def self.ransackable_associations(auth_object = nil)
      ["application"]
    end
  end
end
EOL
  echo "✅ Created Doorkeeper compatibility initializer"
fi

# List of models used by ActiveAdmin
models=(
  "account.rb"
  "api_key.rb"
  "code_set.rb"
  "duplicate.rb"
  "enlistment.rb"
  "failure_group.rb"
  "feedback.rb"
  "job.rb"
  "organization.rb"
  "project.rb"
  "project_security_set.rb"
  "release.rb"
  "sloc_set.rb"
  "vulnerability.rb"
  "project_analysis_job.rb"
  "account_analysis_job.rb"
  "organization_analysis_job.rb"
  "vulnerability_job.rb"
)

# Directory for model files
MODELS_DIR="/Users/kumarin/Library/CloudStorage/OneDrive-BlackDuckSoftware/Desktop/openhub/ohloh-ui/app/models"

# Function to add Ransack compatibility methods to a model file
add_ransack_methods() {
  local file="$1"
  
  # Check if file exists
  if [ ! -f "$file" ]; then
    echo "❌ File not found: $file"
    return
  fi
  
  # Check if methods already exist
  if grep -q "ransackable_attributes" "$file"; then
    echo "✅ Ransack methods already exist in $file"
    return
  fi
  
  # Find appropriate insertion point before the last 'end'
  local last_line=$(grep -n "end" "$file" | tail -1 | cut -d':' -f1)
  
  # Create temporary file
  local temp_file=$(mktemp)
  
  # Copy the file content up to the last 'end'
  head -n $((last_line-1)) "$file" > "$temp_file"
  
  # Add Ransack compatibility methods
  echo "" >> "$temp_file"
  echo "  # Ransack 4.0+ compatibility" >> "$temp_file"
  echo "  def self.ransackable_attributes(auth_object = nil)" >> "$temp_file"
  echo "    authorizable_ransackable_attributes" >> "$temp_file"
  echo "  end" >> "$temp_file"
  echo "" >> "$temp_file"
  echo "  def self.ransackable_associations(auth_object = nil)" >> "$temp_file"
  echo "    authorizable_ransackable_associations" >> "$temp_file"
  echo "  end" >> "$temp_file"
  
  # Add the last 'end'
  echo "end" >> "$temp_file"
  
  # Replace original file with updated content
  mv "$temp_file" "$file"
  echo "✅ Added Ransack methods to $file"
}

# Process each model file
for model_file in "${models[@]}"; do
  echo "Processing $model_file"
  add_ransack_methods "$MODELS_DIR/$model_file"
done

echo "Done!"
