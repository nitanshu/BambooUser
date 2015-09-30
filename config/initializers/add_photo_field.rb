BambooUser.add_photofy do |user_class|
  user_class.photofy :photo, image_processor: Proc.new { |img| img.resize_to_fill(250, 250) }
end