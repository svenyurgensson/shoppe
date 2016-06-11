# coding: utf-8
module Shoppe
  class DashboardController < Shoppe::ApplicationController
    def home
      redirect_to :orders
    end

    def reset
      Rails.cache.clear
      redirect_to :back, notice: 'Сбросили кеш страниц!'
    end
  end
end
