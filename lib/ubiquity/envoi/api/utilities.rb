require 'ubiquity/envoi/api/client'

module Ubiquity
  module Envoi
    module API
      class Utilities < Client

        def content_details_metadata_simplify(content_details, options = { })
          metadata = { }

          groups = content_details['groups'] || [ ]
          groups.each do |group|
            group_label = group['label']
            group_metadata = { }
            values = group['values']
            values.each do |value|

              value_label = value['label']
              value_value = value['value']
              # display_value = value['display_value']
              #
              # value_field = value['field']
              # value_field_id = value_field['id']
              # value_field_uri = value_field['uri']

              md_key = value_label
              md_value = value_value

              group_metadata[md_key] = md_value
            end
            metadata[group_label] = group_metadata
          end

          metadata
        end

        def content_fieldset_get_by_name(args = { }, options = { })
          _name = args[:name]
          _response = content_fieldsets
          _results = _response['results']
          _results.find { |fs| fs['name'] == _name }
        end

        def content_type_by_name(args = { }, options = { })
          # return args.map { |a| content_type_by_name(a, options) } if args.is_a?(Array)

          # _args = Requests::BaseRequest.process_parameters([ { :name => :name } ], args)
          _args ||= args
          _name = _args[:name]
          _response = content_types_get
          _results = _response['results']
          _results.find { |ct| ct['name'] == _name }
        end

        def content_field_group_by(metadata_field_group, options = { })
          if metadata_field_group.is_a?(Array)
            return metadata_field_group.map { |mfg| content_field_group_by(mfg, options) }
          end
          md_field_type = options[:metadata_field_type] || 'label' # label, id | field_uri

          md_out = { }

          metadata_fieldgroup_values = metadata_field_group['values'] || [ ]

          metadata_fieldgroup_values.each do |md_field|
            # md_field_id = md_field['id']
            # md_field_label = md_field['label']
            md_field_value = md_field['value']
            md_field_def = md_field['field']
            # md_field_def_type = md_field_def['type']

            md_field_key = case md_field_type
                             when 'id', 'label'
                               md_field[md_field_type]
                             when 'field_uri'
                               md_field_def['uri']
                           end

            # puts %("#{md_field_id}" => "#{md_field_value}",)
            # md_map[md_field_id] = { md_field_label => { :field_id => md_field_id, :group_id => metadata_fieldgroup_id, :field_type => md_field_def_type } }
            md_out[md_field_key] = md_field_value
          end

          md_out
        end

        def metadata_by(args = { }, options = { })
          entity = args[:entity] || args[:asset] || args[:project]
          metadata_fieldset = args[:metadata] || entity['metadata'] || { }
          md_field_type = args[:metadata_field_type] || 'label' # label, id | field_uri

          md_out = { }


          # metadata_fieldset_id = metadata_fieldset['fieldset_id']
          metadata_fieldset_values = metadata_fieldset['values'] || { }
          # metadata_fieldgroup = metadata_fieldset_values || { }
          # metadata_fieldgroup_id = metadata_fieldgroup['fieldgroup_id']
          metadata_fieldgroup_values = metadata_fieldset_values['values'] || [ ]

          metadata_fieldgroup_values.each do |md_field|
            # md_field_id = md_field['id']
            # md_field_label = md_field['label']
            md_field_value = md_field['value']
            md_field_def = md_field['field']
            # md_field_def_type = md_field_def['type']

            md_field_key = case md_field_type
                             when 'id', 'label'
                               md_field[md_field_type]
                             when 'field_uri'
                               md_field_def['uri']
                           end

            # puts %("#{md_field_id}" => "#{md_field_value}",)
            # md_map[md_field_id] = { md_field_label => { :field_id => md_field_id, :group_id => metadata_fieldgroup_id, :field_type => md_field_def_type } }
            md_out[md_field_key] = md_field_value
          end

          md_out
        end


        def self.content_fieldset_to_metadata_map(content_fieldset_details, options = { })
          fieldset_form = content_fieldset_details['form'] || [ ]
          metadata_map = { }

          key_field_by = options[:key_field_by] || 'label'

          fieldset_group = { }
          fieldset_form.each do |fsf|
            fieldset_group_id = fsf['id']
            fieldset_group_name = fsf['name']

            fieldset_group[fieldset_group_id] = fsf

            field_group_fields = fsf['fields']
            field_group_fields.each do |field|
              field_label = field['label']
              field_name = field['name']
              field_required = field['required']
              field_details = field['field']
              field_type = field_details['type']

              md_map_field_key = field[key_field_by]

              metadata_map[md_map_field_key] = {
                :field_name => field_name, :group_name => fieldset_group_name, :field_type => field_type,
                :field_required => field_required, :field_label => field_label
              }
            end
          end

          return metadata_map
        end

        # Client
      end

      # API
    end

    # Envoi
  end

  # Ubiquity
end