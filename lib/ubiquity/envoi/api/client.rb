require 'logger'

require 'ubiquity/envoi/api/client/http_client'
require 'ubiquity/envoi/api/client/requests'
require 'ubiquity/envoi/api/client/paginator'

module Ubiquity
  module Envoi
    module API
      class Client

        attr_accessor :http_client, :request, :response, :logger

        def initialize(args = { })
          @http_client = HTTPClient.new(args)
          @logger = http_client.logger
        end

        def process_request(request, options = nil)
          @paginator = nil
          @response = nil
          @request = request
          logger.warn { "Request is Missing Required Arguments: #{request.missing_required_arguments.inspect}" } unless request.missing_required_arguments.empty?

          if ([:all, 'all'].include?(request.arguments[:_page]))
            request.arguments[:_page] = 1
            include_remaining_pages = true
          else
            include_remaining_pages = false
          end

          request.client = self unless request.client
          options ||= request.options

          return (options.fetch(:return_request, true) ? request : nil) unless options.fetch(:execute_request, true)

          #@response = http_client.call_method(request.http_method, { :path => request.path, :query => request.query, :body => request.body }, options)
          @response = request.execute

          if request.respond_to?(:success?) && !request.success?
            raise "Request failed. #{request.response.code} #{response.body}"
          end

          if include_remaining_pages
            return paginator.include_remaining_pages
          end

          @response
        end

        def paginator
          @paginator ||= Paginator.new(self, { :logger => logger }) if @response
        end

        def process_request_using_class(request_class, args, options = { })
          @response = nil
          @request = request_class.new(args, options.merge(:client => self))
          process_request(@request, options)
        end

        # Exposes HTTP Methods
        # @example http(:get, '/')
        def http(method, *args)
          @request = nil
          @response = http_client.send(method, *args)
          @request = http_client.request
          @response
        end

        # ############################################################################################################## #
        # @!group API Endpoints

        def content(args = { }, options = { })
          http :get, 'content'
        end

        def content_create(args = { }, options = { })

        end

        def content_details(args = { }, options = { })
          http :get, "content/#{args[:id]}"
        end

        def content_field_details(args = { }, options = { })
          http :get, "content-field/#{args[:id]}"
        end

        def content_fieldset_details(args = { }, options = { })
          http :get, "content-fieldset/#{args[:id]}"
        end

        def content_type_details(args = { }, options = { })
          http :get, "content-type/#{args[:id]}"
        end

        def content_fieldsets(args = { }, options = { })
          http :get, 'content-fieldset'
        end

        def content_types(args = { }, options = { })
          http :get, 'content-type'
        end
        alias :content_types_get :content_types

        def file_get(args = { }, options = { })
          id = args[:id]

          http(:get, "file/#{id}")
        end

        def media_file_create(args = { }, options = { })
          # _request = Requests::BaseRequest.new(
          #   args,
          #   {
          #       :http_path => 'media-files/media-file',
          #       :http_method => :post,
          #       :parameters => [
          #         { :name => :name, :required => true },
          #         { :name => :description },
          #         { :name => :file },
          #         { :name => :metadata },
          #         # { :name => 'file[path]', :aliases => [ :path ], :required => true },
          #         # { :name => 'file[mime]', :aliases => [ :mime, :mime_type ], :required => true },
          #         # { :name => 'file[size]', :aliases => [ :size ], :required => true },
          #         # { :name => 'file[width]', :aliases => [ :width ] }
          #       ]
          #   }.merge(options)
          # )
          # process_request(_request, options)
          process_request_using_class(Requests::MediaFileCreate, args, options)
        end

        def media_file_add_file(args = { }, options = { })
          process_request_using_class(Requests::MediaFileAddFile, args, options)
        end
        alias :media_file_file_add :media_file_add_file

        def media_file_delete(args = { }, options = { })
          id = args[:id]

          http(:delete, "media-files/media-file/#{id}")
        end

        def media_file_get(args = { }, options = { })
          id = args[:id] || args[:media_file_id]

          http(:get, "media-files/media-file/#{id}")
        end

        def media_file_files_get(args = { }, options = { })
          id = args[:id] || args[:media_file_id]

          http(:get, "media-files/media-file/#{id}/files")
        end

        def media_file_secured_get(args = { }, options = { })
          _request = Requests::BaseRequest.new(
              args,
              {
                  :http_path => 'media-files/media-file/#{path_arguments[:media_file_id]}/secure',
                  :http_method => :post,
                  # :body => args,
                  :parameters => [
                      { :name => :media_file_id, :aliases => [ :id ], :send_in => :path },
                      { :name => :email, :send_in => :body },
                  ]
              }
          )
          process_request(_request, options)
        end


        # Transcode a Media File
        #
        # @param [Hash] args
        # @option args [String] :media_file_id
        # @option args [String] :transcoder_id
        # @option args [Hash] :transcoder_args
        # @see http://envoi.io/api/documentation/media-files/media-files-transcode
        def media_file_transcode(args = { }, options = { })
          media_file_id = args[:media_file_id]
          transcoder_id = args[:transcoder_id]
          transcoder_args = args[:transcoder_args] || {}

          http(:post, "media-files/media-file/#{media_file_id}/action/transcode/#{transcoder_id}", transcoder_args)
        end

        def media_file_transcode_parameters_get(args = { }, options = { })
          media_file_id = args[:media_file_id]
          transcoder_id = args[:transcoder_id]

          http(:get, "media-files/media-file/#{media_file_id}/action/transcode/#{transcoder_id}")
        end

        def media_file_transcoders_get(args = { }, options = { })
          media_file_id = args[:media_file_id] || args[:id]

          http(:get, "media-files/media-file/#{media_file_id}/action/transcode")
        end

        def media_file_update(args = { }, options = { })
          process_request_using_class(Requests::MediaFileUpdate, args, options)
        end

        def media_files_get(args = { }, options = { })
          # http(:get, 'media-files/media-file?_perPage=200')

          _request = Requests::BaseRequest.new(
              args,
              {
                  :http_path => 'media-files/media-file',
                  :parameters => [
                      { :name => :_perPage, :default_value => '200' },
                      { :name => :_page, :default_value => '1' }
                  ]
              }
          )
          process_request(_request, options)
        end

        def media_files_detailed_get(args = { }, options = { })
          # http(:get, 'media-files/media-file-detailed?_perPage=200')

          _request = Requests::BaseRequest.new(
              args,
              {
                  :http_path => 'media-files/media-file-detailed',
                  :parameters => [
                      { :name => :_perPage, :aliases => [ :perPage ], :default_value => '200' },
                      { :name => :_page, :alises => [ :page ], :default_value => '1' }
                  ]
              }
          )
          process_request(_request, options)
        end

        def project_get(args = { }, options = { })
          _request = Requests::BaseRequest.new(
            args,
            {
              :http_path => 'production/project/#{path_arguments[:project_id]}',
              :parameters => [
                { :name => :project_id, :aliases => [ :id ], :send_in => :path }
              ]
            }
          )

          process_request(_request, options)
        end

        def projects_get(args = { }, options = { })
          _request = Requests::BaseRequest.new(
            args,
            {
              :http_path => 'production/project',
              :parameters => [

              ]
            }
          )

          process_request(_request, options)
        end

        def storages_get(args = { }, options = { })
          http(:get, 'media-files/storage')
        end

        def user_create(args = { }, options = { })

        end

        def who
          http :get, 'who'
        end

        # @!endgroup API Endpoints
        # ############################################################################################################## #

        # Client
      end

      # API
    end

    # Envoi
  end

  # Ubiquity
end