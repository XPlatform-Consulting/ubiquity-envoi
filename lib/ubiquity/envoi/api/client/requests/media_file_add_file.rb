module Ubiquity::Envoi::API::Client::Requests

  # @see http://www.envoi.io/api/documentation/media-files/media-files-file-add
  class MediaFileAddFile < BaseRequest

    HTTP_METHOD = :post
    HTTP_PATH = '/media-files/media-file/#{path_arguments[:media_file_id]}/file'
    DEFAULT_PARAMETER_SEND_IN_VALUE = :body

    PARAMETERS = [
      { :name => :media_file_id, :aliases => [ :id ], :required => true, :send_in => :path },
      { :name => :shape_type, :aliases => [ :type ], :required => true },
      { :name => :shape_label, :aliases => [ :label ], :required => true },
      { :name => :name, :required => true },
      { :name => :mime, :required => true },
      { :name => :path },
      { :name => :size, :required => true },
      { :name => :width },
      { :name => :height },
      { :name => :duration },
      { :name => :setting_id },
      { :name => :storage_key },
      { :name => :storage_info },
      { :name => :uri, :aliases => [ :url ] }
    ]

    def after_process_parameters
      # arguments.delete(:folderId) if arguments[:folderId].to_s == '0'
    end

  end

end