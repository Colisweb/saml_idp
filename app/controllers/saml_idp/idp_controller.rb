# encoding: utf-8
module SamlIdp
  class IdpController < ActionController::Base
    include SamlIdp::Controller

    unloadable unless Rails::VERSION::MAJOR >= 4
    protect_from_forgery
    before_filter :validate_saml_request, only: [:new, :create]

    def new
      render template: saml_idp_new_template_path
    end

    def show
      render xml: SamlIdp.metadata.signed
    end

    def create
      unless params[:email].blank? && params[:password].blank?
        person = idp_authenticate(params[:email], params[:password])
        if person.nil?
          redirect_to :back, alert: 'Login failed'
        else
          @saml_response = idp_make_saml_response(person)
          render :template => saml_idp_post_template_path
        end
      else
        render :template => saml_idp_new_template_path
      end
      
    end

    def logout
      idp_logout
      @saml_response = idp_make_saml_response(nil)
      render :template => saml_idp_post_template_path
    end

    def idp_logout
      raise NotImplementedError
    end
    private :idp_logout

    def idp_authenticate(email, password)
      raise NotImplementedError
    end
    protected :idp_authenticate

    def idp_make_saml_response(person)
      raise NotImplementedError
    end
    protected :idp_make_saml_response

    def saml_idp_new_template_path
      "saml_idp/idp/new"
    end

    def saml_idp_post_template_path
      "saml_idp/idp/saml_post"
    end
  end
end
