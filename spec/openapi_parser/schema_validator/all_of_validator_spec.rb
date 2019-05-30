require_relative '../../spec_helper'

RSpec.describe OpenAPIParser::Schemas::RequestBody do
  let(:root) { OpenAPIParser.parse(petstore_with_discriminator_schema, {}) }

  describe 'allOf nested objects' do
    let(:content_type) { 'application/json' }
    let(:http_method) { :post }
    let(:request_path) { '/save_the_pets' }
    let(:request_operation) { root.request_operation(http_method, request_path) }
    let(:params) { {} }

    context "without additionalProperties defined" do
      it 'passes when sending all properties' do
        body = {
          "baskets" => [
            {
              "name"       => "dragon",
              "mass"       => 10,
              "fire_range" => 20
            }
          ]
        }
        request_operation.validate_request_body(content_type, body)
      end

      it 'fails when sending unknown properties' do
        body = {
          "baskets" => [
            {
              "name"       => "dragon",
              "mass"       => 10,
              "fire_range" => 20,
              "speed"      => 20
            }
          ]
        }

        expect { request_operation.validate_request_body(content_type, body) }.to raise_error do |e|
          expect(e.kind_of?(OpenAPIParser::NotExistPropertyDefinition)).to eq true
          expect(e.message).to match("^properties speed are not defined in.*?$")
        end
      end

      it 'fails when missing required property' do
        body = {
          "baskets" => [
            {
              "name"       => "dragon",
              "mass"       => 10,
            }
          ]
        }

        expect { request_operation.validate_request_body(content_type, body) }.to raise_error do |e|
          expect(e.kind_of?(OpenAPIParser::NotExistRequiredKey)).to eq true
          expect(e.message).to match("^required parameters fire_range not exist .*?$")
        end
      end
    end

    context "with additionalProperties defined" do
      it 'passes when sending all properties' do
        body = {
          "baskets" => [
            {
              "name"       => "hydra",
              "mass"       => 10,
              "head_count" => 20
            }
          ]
        }
        request_operation.validate_request_body(content_type, body)
      end

      it 'succeeds when sending unknown properties of correct type based on additionalProperties' do
        body = {
          "baskets" => [
            {
              "name"       => "hydra",
              "mass"       => 10,
              "head_count" => 20,
              "speed"      => "20"
            }
          ]
        }

        request_operation.validate_request_body(content_type, body)
      end

      it 'fails when sending unknown properties of correct type based on additionalProperties' do
        body = {
          "baskets" => [
            {
              "name"       => "hydra",
              "mass"       => 10,
              "head_count" => 20,
              "speed"      => 20
            }
          ]
        }

        # TODO for now we don't validate on additionalProperites, but this should fail on speed have to be string
        request_operation.validate_request_body(content_type, body)
      end

      it 'fails when missing required property' do
        body = {
          "baskets" => [
            {
              "name"       => "hydra",
              "mass"       => 10,
            }
          ]
        }

        expect { request_operation.validate_request_body(content_type, body) }.to raise_error do |e|
          expect(e.kind_of?(OpenAPIParser::NotExistRequiredKey)).to eq true
          expect(e.message).to match("^required parameters head_count not exist .*?$")
        end
      end
    end
  end
end
