module Jobs
  class ResizePhoto
    extend ResqueJobLogging
    @queue = :resize_photo
    def self.perform(photo_id)
      photo = Photo.find(photo_id)
      photo.post_process
    end
  end
end
