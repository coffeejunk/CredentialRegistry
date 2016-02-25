FactoryGirl.define do
  factory :document do
    doc_type :resource_data
    doc_version '0.51.1'
    user_envelope { JWT.encode({ resource_data: 'contents' }, nil, 'none') }
    user_envelope_format :jwt
    node_headers { JWT.encode({ header: 'value' }, nil, 'none') }
    node_headers_format :node_headers_jwt

    factory :document_with_id do
      doc_id 'ac0c5f52-68b8-4438-bf34-6a63b1b95b56'
    end
  end
end