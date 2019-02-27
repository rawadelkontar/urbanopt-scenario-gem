########################################################################################################################
#  openstudio(R), Copyright (c) 2008-2019, Alliance for Sustainable Energy, LLC. All rights reserved.
#
#  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the
#  following conditions are met:
#
#  (1) Redistributions of source code must retain the above copyright notice, this list of conditions and the following
#  disclaimer.
#
#  (2) Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the
#  following disclaimer in the documentation and/or other materials provided with the distribution.
#
#  (3) Neither the name of the copyright holder nor the names of any contributors may be used to endorse or promote
#  products derived from this software without specific prior written permission from the respective party.
#
#  (4) Other than as required in clauses (1) and (2), distributions in any form of modifications or other derivative
#  works may not use the "openstudio" trademark, "OS", "os", or any other confusingly similar designation without
#  specific prior written permission from Alliance for Sustainable Energy, LLC.
#
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
#  INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER, THE UNITED STATES GOVERNMENT, OR ANY CONTRIBUTORS BE LIABLE FOR
#  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
#  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
#  AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
#  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
########################################################################################################################

require "openstudio/extension"

module URBANopt
  module Scenario
    class ScenarioDatapoint 
    
      attr_accessor :scenario, :feature_id, :feature_name, :mapper_class
      
      def initialize(scenario)
        @scenario = scenario
      end
      
      def run_dir
        raise "Feature ID not set" if @feature_id.nil?
        raise "Scenario run dir not set" if @scenario.run_dir.nil?
        return File.join(@scenario.run_dir, @feature_id + '/')
      end
      
      def create_osw
        osw = eval("#{@mapper_class}.new.create_osw(@scenario, @feature_id, @feature_name)")
        dir = run_dir
        FileUtils.rm_rf(dir) if File.exists?(dir)
        FileUtils.mkdir_p(dir) if !File.exists?(dir)
        osw_path = File.join(dir, 'in.osw')
        File.open(osw_path, 'w') do |f|
          f << JSON.pretty_generate(osw) 
          # make sure data is written to the disk one way or the other
          begin
            f.fsync
          rescue
            f.flush
          end
        end
        return osw_path
      end
      
    end
  end
end