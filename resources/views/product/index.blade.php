<h1>Product Page</h1>

<p>Products count:
{{ $product->count() }}
</p>

@foreach($product as $row)
    <p>{{ $row->product_name }}</p>
@endforeach
