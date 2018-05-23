        x= {
          # hashed from the :full_relation_name to avoid conflicts
          "integrationtestdatabase${var.deployment_id}" =>
          {
            'Type' => 'AWS::Glue::Database',
            'Properties' => {
              # terraform will populate this for you based upon the aws account
              'CatalogId' => '${data.aws_caller_identity.current.account_id}',
              'DatabaseInput' => {
                'Name' => "integration_test_database${var.deployment_id}",
                'Parameters' => {
                  'convergdb_deployment_id' =>
                    '${var.deployment_id}'
                }
              }
            }
          }
        }
        
require 'json'
h= {val: x.to_json}
puts h.to_json