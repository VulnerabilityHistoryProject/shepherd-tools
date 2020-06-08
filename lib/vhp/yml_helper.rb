module VHP
  module YMLHelper
    def load_yml_the_vhp_way(f)
      YAML.load(File.open(f), symbolize_names: true)
    end
  end
end
