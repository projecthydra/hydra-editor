require 'spec_helper'

describe HydraEditor::Form do
  before do
    class TestModel < ActiveFedora::Base
      property :title, predicate: ::RDF::DC.title
      property :creator, predicate: ::RDF::DC.creator, multiple: false
    end

    class TestForm
      include HydraEditor::Form
      self.model_class = TestModel
      # Terms is the list of fields displayed by app/views/records/_form.html.erb
      self.terms = [:title, :creator]
    end
  end

  after do
    Object.send(:remove_const, :TestForm)
    Object.send(:remove_const, :TestModel)
  end

  describe "class methods" do
    subject { TestForm.model_name }
    it { is_expected.to eq 'TestModel' }

    describe "model_attributes" do
      let(:params) { ActionController::Parameters.new(title: [''], creator: 'bob', description: ['huh']) }
      subject { TestForm.model_attributes(params) }

      it { is_expected.to eq('creator' => 'bob', 'title' => []) }
    end
  end

  let(:object) { TestModel.new(title: ['foo', 'bar'], creator: 'baz') }
  let(:form) { TestForm.new(object) }

  describe "#terms" do
    subject { form.terms }
    it { is_expected.to eq [:title, :creator] }
  end

  describe "the term accessors" do
    it "should have the accessors" do
      expect(form.title).to eq ['foo', 'bar']
      expect(form.creator).to eq 'baz'
    end

    it "should have the hash accessors" do
      expect(form[:title]).to eq ['foo', 'bar']
      expect(form[:creator]).to eq 'baz'
    end
  end

  describe "#initialize_field" do
    before do
      form[:title] = nil
    end

    it "should put an empty element in the value" do
      expect { form.send(:initialize_field, :title) }.to change { form[:title] }.
        from(nil).to([''])
    end
  end

  describe "#errors" do
    let(:errors) { double(:errors) }
    before do
      allow(object).to receive(:errors).and_return(errors)
    end
    it "should delegate to model" do
      expect(form.errors).to eq errors
    end
  end

  describe ".validators_on" do
    context "with required fields" do
      before do
        TestForm.required_fields = [:title]
      end
      it "should create them for required fields" do
        expect(TestForm.validators_on(:title).first).to be_instance_of HydraEditor::Form::Validator
        expect(TestForm.validators_on(:title).first.options).to eq({})
        expect(TestForm.validators_on(:title).first.kind).to eq :presence
      end
    end
    context "without required fields" do
      it "should create them for required fields" do
        expect(TestForm.validators_on(:title)).to eq []
      end
    end

  end

  describe "#generate_input" do
    let(:generator_class) { class_double(HydraEditor::Fields::Generator) }
    let(:generator) { instance_double(HydraEditor::Fields::Generator) }

    it "delegates to the field generator" do
      expect(form).to receive(:field_generator).and_return(generator_class)
      expect(generator_class).to receive(:new).with(:form, :key).and_return(generator)
      expect(generator).to receive(:input)

      form.generate_input(:form, :key)
    end
  end

  describe "#field_generator" do
    context "when left untouched" do
      it "defaults to HydraEditor::Fields::Generator" do
        expect(form.field_generator).to eq(HydraEditor::Fields::Generator)
      end
    end
  end
end
