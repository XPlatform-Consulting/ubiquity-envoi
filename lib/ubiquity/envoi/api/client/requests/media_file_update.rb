module Ubiquity::Envoi::API::Client::Requests

  # @see http://www.envoi.io/api/documentation/media-files/media-files-update
  class MediaFileUpdate < BaseRequest

    HTTP_METHOD = :put
    HTTP_PATH = '/media-files/media-file/#{path_arguments[:media_file_id]}'
    DEFAULT_PARAMETER_SEND_IN_VALUE = :body

    PARAMETERS = [
      { :name => :media_file_id, :aliases => [ :id ], :required => true, :send_in => :path },
      { :name => :name },
      { :name => :description },
      { :name => :file, :required => true },
      { :name => :metadata },
      { :name => :content_fieldset_id },
      { :name => :metadata }
    ]

    def after_process_parameters
      # arguments.delete(:folderId) if arguments[:folderId].to_s == '0'
    end

  end

end