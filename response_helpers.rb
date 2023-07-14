module ResponseHelpers
  def ok_response(content='')
    ['200', {}, [content]]
  end

  def created_response(object_id, content)
    response = { 'oid' => object_id, 'size' => content.length }.to_json
    ['201', { 'Content-Type' => 'application/json' }, [response]]
  end

  def not_found_response
    ['404', {}, ['Not Found']]
  end

  def method_not_allowed
    ['405', { 'Allow' => 'GET, PUT, DELETE' }, ['Method Not Allowed']]
  end
end
