module Api
    module V1
        class LeftoversController < ApplicationController
            def index
                a = Remains::Worker.new
                begin
                a.connect
                rescue
                raise Remains::MyError.new("Не удалось соединиться с бд", "my thing")
                end
                if a.active?
                @result = a.execute
                else
                
                end
            end
            
        end
    end
end
