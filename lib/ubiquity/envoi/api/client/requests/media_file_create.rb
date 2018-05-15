module Ubiquity::Envoi::API::Client::Requests

  # @see http://www.envoi.io/api/documentation/media-files/media-files-add
  class MediaFileCreate < BaseRequest

    HTTP_METHOD = :post
    HTTP_PATH = '/media-files/media-file'
    DEFAULT_PARAMETER_SEND_IN_VALUE = :body

    PARAMETERS = [
      { :name => :name, :required => true },
      { :name => :description, :required => true },
      { :name => :file, :required => true },
      { :name => :metadata },
      { :name => :content_fieldset_id },
    ]

    def after_process_parameters
      # arguments.delete(:folderId) if arguments[:folderId].to_s == '0'
    end

  end

end