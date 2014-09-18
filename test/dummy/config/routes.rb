Rails.application.routes.draw do

  mount BambooUser::Engine => "/bamboo_user"
end
