require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "XmlMapper" do
  before(:each) do
    @mapper = XmlMapper.new
  end
  
  describe "#add_mapping" do
    it "adds the correct mappings when only one symbol given" do
      @mapper.add_mapping(:text, :title)
      @mapper.mappings.should == [{ :type => :text, :xpath => "title", :key => :title, :options => {} }]
    end
    
    it "adds the correct mapping when type is not text" do
      @mapper.add_mapping(:length, :title)
      @mapper.mappings.should == [{ :type => :length, :xpath => "title", :key => :title, :options => {} }]
    end
    
    it "adds multiple mappings when more symbols given" do
      @mapper.add_mapping(:text, :first_name, :last_name)
      @mapper.mappings.should == [
        { :type => :text, :xpath => "first_name", :key => :first_name, :options => {} },
        { :type => :text, :xpath => "last_name", :key => :last_name, :options => {} },
      ]
    end
    
    it "adds mappings when mapping given as hash" do
      @mapper.add_mapping(:text, :name => :first_name)
      @mapper.mappings.should == [{ :type => :text, :xpath => "name", :key => :first_name, :options => {} }]
    end
    
    it "adds mappings with options when mapping given as symbols and last arg is hash" do
      @mapper.add_mapping(:text, :name, :born, :after_map => :to_s)
      @mapper.mappings.should == [
        { :type => :text, :xpath => "name", :key => :name, :options => { :after_map => :to_s } },
        { :type => :text, :xpath => "born", :key => :born, :options => { :after_map => :to_s } },
      ]
    end
  end
  
  describe "map text attributes" do
    before(:each) do
      @xml = %(
      <album>
        <title>Black on Both Sides</title>
        <artist_name>Mos Def</artist_name>
        <track_number>7</track_number>
      </album>)
    end
    
    it "maps the correct inner text when node found" do
      @mapper.add_mapping(:text, :artist_name, :title)
      @mapper.attributes_from_xml(@xml).should == { :title => "Black on Both Sides", :artist_name => "Mos Def" }
    end
    
    describe "#exists" do
      it "returns true when node exists" do
        xml = %(<album><title>Black on Both Sides</title><rights><country>DE</country></rights></album>)
        @mapper.add_mapping(:exists, "rights[country='DE']" => :allows_streaming)
        @mapper.attributes_from_xml(xml).should == { :allows_streaming => true }
      end
      
      it "returns false when node does not exist" do
        xml = %(<album><title>Black on Both Sides</title><rights><country>DE</country></rights></album>)
        @mapper.add_mapping(:exists, "rights[country='FR']" => :allows_streaming)
        @mapper.attributes_from_xml(xml).should == { :allows_streaming => false }
      end
    end
    
    it "maps not found nodes to nil" do
      @mapper.add_mapping(:text, :artist_name, :version_title, :long_title)
      @mapper.attributes_from_xml(@xml).should == { 
        :version_title => nil, :long_title => nil, :artist_name => "Mos Def"
      }
    end
    
    it "converts integers to integer when found" do
      @mapper.add_mapping(:text, :artist_name)
      @mapper.add_mapping(:integer, :track_number)
      @mapper.attributes_from_xml(@xml).should == {
        :track_number => 7, :artist_name => "Mos Def"
      }
    end
    
    it "does not convert nil to integer for integer type" do
      @mapper.add_mapping(:text, :artist_name)
      @mapper.add_mapping(:integer, :track_number, :set_count)
      @mapper.attributes_from_xml(@xml).should == {
        :track_number => 7, :artist_name => "Mos Def", :set_count => nil
      }
    end
    
    it "calls method with name type on value when found and responding" do
      @mapper.add_mapping(:text, :artist_name, :after_map => :upcase)
      @mapper.attributes_from_xml(@xml).should == {
        :artist_name => "MOS DEF"
      }
    end
    
    it "uses mapper method defined in xml_mapper when after_map does not respond to :upcase" do
      class << @mapper
        def double(value)
          value.to_s * 2
        end
      end
      
      @mapper.add_mapping(:text, :artist_name, :after_map => :double)
      @mapper.attributes_from_xml(@xml).should == {
        :artist_name => "Mos DefMos Def"
      }
    end
    
    it "takes a nokogiri node as argument" do
      @mapper.add_mapping(:text, :artist_name)
      @mapper.attributes_from_xml(Nokogiri::XML(@xml)).should == {
        :artist_name => "Mos Def"
      }
    end
    
    it "should also takes an array of nodes as argument" do
      @mapper.add_mapping(:text, :artist_name)
      @mapper.attributes_from_xml([Nokogiri::XML(@xml), Nokogiri::XML(@xml)]).should == [
        { :artist_name => "Mos Def" },
        { :artist_name => "Mos Def" }
      ]
    end
    
    describe "mapping embedded attributes" do
      before(:each) do
        @xml = %(
          <album>
            <artist_name>Mos Def</artist_name>
            <tracks>
              <track>
                <track_number>1</track_number>
                <title>Track 1</title>
              </track>
              <track>
                <track_number>2</track_number>
                <title>Track 2</title>
              </track>
            </tracks>
          </album>
        )
      end
      
      it "maps all embedded attributes" do
        submapper = XmlMapper.new
        submapper.add_mapping(:integer, :track_number)
        submapper.add_mapping(:text, :title)
        @mapper.add_mapping(:text, :artist_name)
        @mapper.add_mapping(:many, { "tracks/track" => :tracks }, :mapper => submapper)
        @mapper.attributes_from_xml(@xml).should == { 
          :artist_name => "Mos Def",
          :tracks => [
            { :title => "Track 1", :track_number => 1 },
            { :title => "Track 2", :track_number => 2 },
          ]
        }
      end
    end
  end
  
  describe "#attributes_from_xml_path" do
    before(:each) do
      @mapper.add_mapping(:text, :title)
      @xml = %(
        <album>
          <title>Black on Both Sides</title>
        </album>
      )
      File.stub(:read).and_return @xml
    end
    
    it "sets the xml_path" do
      @mapper.attributes_from_xml_path("/some/path.xml").should == { 
        :title => "Black on Both Sides", :xml_path => "/some/path.xml" 
      }
    end
    
    it "calls File.read with correct parameters" do
      File.should_receive(:read).with("/some/path.xml").and_return @xml
      @mapper.attributes_from_xml_path("/some/path.xml")
    end
  end
  
  describe "#after_map" do
    before(:each) do
      @mapper.after_map do
        self[:upc] = "1234"
      end
    end
    
    it "assigns after_map block" do
      @mapper.after_map_block.should_not be_nil
    end
    
    it "assigns a block to after_map_block" do
      @mapper.after_map_block.should be_an_instance_of(Proc)
    end
    
    it "should executes after_map block after mapping" do
      @mapper.attributes_from_xml("<album><title>Some Titel</title></album>").should == {
        :upc => "1234"
      }
    end
  end
  
  describe "converting strings" do
    describe "#string_to_boolean" do
      { 
        "true" => true, "false" => false, "y" => true, "TRUE" => true, "" => nil, "YES" => true, "yes" => true,
        "n" => false
      }.each do |value, result|
        it "converts #{value.inspect} to #{result}" do
          @mapper.string_to_boolean(value).should == result
        end
      end
    end
  end
  
  describe "defining a DSL" do
    before(:each) do
      # so that we have a new class in each spec
      class_name = "TestMapping#{Time.now.to_f.to_s.gsub(".", "")}"
      str = %(
        class #{class_name} < XmlMapper
        end
      )
      eval(str)
      @clazz = eval(class_name)
    end
    
    it "sets the correct mapping for map keyword" do
      @clazz.text(:title)
      @clazz.mapper.mappings.should == [{ :type => :text, :key => :title, :xpath => "title", :options => {} }]
    end
    
    it "sets the correct mapping for text keyword" do
      @clazz.integer(:title)
      @clazz.mapper.mappings.should == [{ :type => :integer, :key => :title, :xpath => "title", :options => {} }]
    end
    
    it "allows getting attributes form xml_path" do
      File.stub(:read).and_return %(<album><title>Test Title</title></album>)
      @clazz.text(:title)
      @clazz.attributes_from_xml_path("/some/path.xml").should == {
        :title => "Test Title",
        :xml_path => "/some/path.xml"
      }
    end
    
    it "allows defining a after_map block" do
      @clazz.after_map do
        self[:upc] = "1234"
      end
      @clazz.text(:title)
      @clazz.attributes_from_xml(%(<album><title>Test Title</title></album>)).should == {
        :upc => "1234", :title => "Test Title"
      }
    end
    
    it "accepts boolean as keyword" do
      @clazz.boolean(:allows_streaming)
      xml = %(<album><title>Test Title</title><allows_streaming>true</allows_streaming></album>)
      @clazz.attributes_from_xml(xml).should == { :allows_streaming => true }
    end
    
    it "accepts exists as keyword" do
      @clazz.exists("rights[country='DE']" => :allows_streaming)
      xml = %(<album><title>Black on Both Sides</title><rights><country>DE</country></rights></album>)
      @clazz.attributes_from_xml(xml).should == { :allows_streaming => true }
    end
    
    describe "#within" do
      it "adds the within xpath to all xpath mappings" do
        @clazz.within("artist") do
          text :name => :artist_name
          integer :id => :artist_id
        end
        @clazz.mapper.mappings.should == [
          { :type => :text, :xpath => "artist/name", :key => :artist_name, :options => {} },
          { :type => :integer, :xpath => "artist/id", :key => :artist_id, :options => {} },
        ]
      end
      
      it "adds all nested within xpaths to xpath mappings" do
        @clazz.within("contributions") do
          within "artist" do
            text :name => :artist_name 
            integer :id => :artist_id
          end
        end
        @clazz.mapper.mappings.should == [
          { :type => :text, :xpath => "contributions/artist/name", :key => :artist_name, :options => {} },
          { :type => :integer, :xpath => "contributions/artist/id", :key => :artist_id, :options => {} },
        ]
      end
      
      it "allows multiple within blocks on same level" do
        @clazz.within "artist" do
          text :name => :artist_name 
        end
        @clazz.within "file" do
          text :file_name
        end
        @clazz.mapper.mappings.should == [
          { :type => :text, :xpath => "artist/name", :key => :artist_name, :options => {} },
          { :type => :text, :xpath => "file/file_name", :key => :file_name, :options => {} },
        ]
      end
    end
    
    describe "defining a submapper" do
      before(:each) do
        @clazz.many("tracks/track" => :tracks) do
          text :title
          integer :track_number
        end
      end
      
      it "sets the mapping type to many" do
        @clazz.mapper.mappings.first[:type].should == :many
      end
      
      it "sets the mapping key to track" do
        @clazz.mapper.mappings.first[:key].should == :tracks
      end
      
      it "sets the mapping xpath to tracks/track" do
        @clazz.mapper.mappings.first[:xpath].should == "tracks/track"
      end
      
      it "sets the correct submapper" do
        @clazz.mapper.mappings.first[:options][:mapper].mappings.should == [
          { :type => :text, :key => :title, :xpath => "title", :options => {} },
          { :type => :integer, :key => :track_number, :xpath => "track_number", :options => {} },
        ]
      end
      
      it "attributes_from_xml returns the correct attributes" do
        @clazz.text(:artist_name)
        @clazz.text(:title)
        xml = %(
          <album>
            <artist_name>Mos Def</artist_name>
            <title>Black on Both Sides</title>
            <tracks>
              <track>
                <title>Track 1</title>
                <track_number>1</track_number>
              </track>
              <track>
                <title>Track 2</title>
                <track_number>2</track_number>
              </track>
            </tracks>
          </album>
        )
        @clazz.attributes_from_xml(xml).should == {
          :artist_name => "Mos Def", :title => "Black on Both Sides",
          :tracks => [
            { :title => "Track 1", :track_number => 1 },
            { :title => "Track 2", :track_number => 2 }
          ]
        }
      end
    end
  
  end
end
