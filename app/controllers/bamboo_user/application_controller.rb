module BambooUser
  #class ApplicationController < ActionController::Base
  class ApplicationController < ::ApplicationController

    attr_accessor :root_owner
    attr_accessor :root_owner_reflection

    before_filter :check_root_owner

    def check_root_owner
      if BambooUser.owner_available?
        begin
          if root_element.is_a?(BambooUser.owner_class_name.constantize) and
              (root_element.send(BambooUser.owner_class_reverse_association).class == BambooUser::User::ActiveRecord_Associations_CollectionProxy)
            @root_owner = root_element
            @root_owner_reflection = root_element.send(BambooUser.owner_class_reverse_association)
          end
        rescue Exception => e
          puts <<-eos
            "Add a method or variable named root_element(most probably in ApplicationController) which
            should return an instance of #{BambooUser.owner_class_name}
            which should have a :has_one or :has_many association to #{BambooUser::User.name}"
          eos
          raise e
        end
      end
    end

    def fetch_model_reflection
      @model = if BambooUser.owner_available? #TODO: Need to implement STI over root_element driven user too
                 root_owner_reflection
               elsif params[:sti_identifier].nil?
                 User
               else
                 _class_name = BambooUser.white_listed_sti_classes[params[:sti_identifier]]
                 if _class_name.nil?
                   raise 'InvalidStiClass'
                 else
                   _class = _class_name.constantize
                   if BambooUser::User.descendants.include?(_class)
                     _class
                   else
                     raise 'InvalidStiClass'
                   end
                 end
               end
    end
  end
end
