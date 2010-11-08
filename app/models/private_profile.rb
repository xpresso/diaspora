#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class PrivateProfile
  include MongoMapper::EmbeddedDocument
  
  key :first_name, String
  key :last_name,  String
  key :image_url,  String
  key :birthday,   Date
  key :gender,     String
  key :bio,        String
 
end
