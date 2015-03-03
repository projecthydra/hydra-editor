require 'spec_helper'

describe HydraEditor::Form do
  before do
    class TestModel < ActiveFedora::Base
      property :title, predicate: ::RDF::DC.title
      property :creator, predicate: ::RDF::DC.creator, multiple: false
      property :abstract, predicate: ::RDF::DC.abstract, multiple: false
    end

    class TestForm
      include HydraEditor::Form
      self.model_class = TestModel
      # Terms is the list of fields displayed by app/views/records/_form.html.erb
      self.terms = [:title, :creator, :abstract]
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
      let(:params) { ActionController::Parameters.new(
        title: [''], creator: 'bob', description: ['huh'], abstract: '' ) }
      subject { TestForm.model_attributes(params) }

      it { is_expected.to eq('creator' => 'bob', 'title' => [], 'abstract' => nil) }
    end
  end

  let(:object) { TestModel.new(title: ['foo', 'bar'], creator: 'baz') }
  let(:form) { TestForm.new(object) }

  describe "#terms" do
    subject { form.terms }
    it { is_expected.to eq [:title, :creator, :abstract] }
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
end
