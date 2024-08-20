# S3::Light 🚀

S3::Light is a fast, lightweight Ruby gem for interacting with S3-compatible storage services. It's designed to be simple, efficient, and powerful! 💪

## Features 🌟

- 🚄 Lightning-fast performance
- 🪶 Lightweight design
- 🔧 Easy to use and integrate
- 📦 Batch operations support
- 🔄 Concurrent processing
- 🔌 Compatible with S3 and S3-like services (e.g., MinIO)
- 🔁 Connection reuse and keep-alive
- 🧵 Thread-safe connection management

## Installation 📥

Add this line to your application's Gemfile:

```ruby
gem 's3-light'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install s3-light

## Usage 🛠️

### Basic Operations

```ruby
# Initialize the client
client = S3Light::Client.new(
  access_key_id: 'your_access_key',
  secret_access_key: 'your_secret_key',
  region: 'us-east-1'
)

# List all buckets
buckets = client.buckets.all

# Create a new bucket
new_bucket = client.buckets.new(name: 'my-awesome-bucket').save!

# Upload an object
object = new_bucket.objects.new(key: 'hello.txt', input: 'Hello, World!').save!

# Download an object
downloaded_content = object.download(to: '/tmp/hello.txt')

# Delete an object
object.destroy!

# Delete a bucket
new_bucket.destroy!
```

### Batch Operations 🎛️

S3::Light shines when it comes to batch operations! Here are some examples:

```ruby
# Create multiple buckets at once
new_buckets = client.buckets.create_batch(names: ['bucket1', 'bucket2', 'bucket3'])

# Check if multiple buckets exist
existence = client.buckets.exists_batch?(names: ['bucket1', 'bucket2', 'nonexistent-bucket'])

# Upload multiple objects concurrently
bucket = client.buckets.find_by(name: 'my-bucket')
objects = bucket.objects.create_batch(
  input: {
    'file1.txt' => 'Content 1',
    'file2.txt' => 'Content 2',
    'file3.txt' => File.open('path/to/file3.txt')
  },
  concurrency: 5
)

# Download multiple objects concurrently
downloads = bucket.objects.download_batch(
  keys: ['file1.txt', 'file2.txt', 'file3.txt'],
  to: '/tmp',
  concurrency: 5
)
```

## Performance 🏎️

S3::Light is designed to be fast and efficient. Here's how it achieves its high performance:

# S3::Light 🚀

... [previous content remains the same] ...

## Performance Benchmarks 📊

We've conducted benchmarks comparing S3::Light with the Amazon S3 gem. The benchmark tests include uploading and downloading a 50MB file 50 times individually.

Here's a summary of the benchmark results:

| Operation         | S3::Light | Amazon S3 Gem | Performance Difference |
|-------------------|-----------|---------------|------------------------|
| Individual Upload | 22.56s    | 37.98s        | 41% faster             |
| Individual Download | 27.24s  | 28.38s        | 4% faster              |

These results demonstrate that S3::Light offers significant performance improvements for individual upload operations and is slightly faster for individual downloads.

S3::Light shows its strength in:
- Individual file uploads (41% faster)
- Individual file downloads (4% faster)

It's important to note that performance can vary depending on factors such as network conditions, server load, and specific use cases. We recommend running benchmarks in your own environment to get the most accurate results for your specific use case.

### Key Observations:

1. **Individual Uploads**: S3::Light significantly outperforms the Amazon S3 gem, completing the task in about 59% of the time taken by the Amazon S3 gem.

2. **Individual Downloads**: S3::Light is slightly faster than the Amazon S3 gem, with a small but noticeable performance advantage.

These results highlight S3::Light's efficiency in handling individual file operations, particularly uploads, which could be beneficial for applications that frequently deal with single-file transfers.

You can find the full benchmark script in the `benchmark` directory of this repository. Feel free to run it yourself and compare the results in your specific environment.

... [rest of the content remains the same] ...

### Connection Reuse and Keep-Alive 🔁

S3::Light implements connection reuse and keep-alive strategies to minimize the overhead of establishing new connections for each request. This significantly reduces latency, especially for applications that make frequent API calls.

```ruby
# The client automatically reuses connections
client.buckets.all  # First request establishes a connection
client.buckets.all  # Subsequent requests reuse the same connection
```

### Connection Pooling 🏊

For concurrent operations, S3::Light uses a connection pool. This allows multiple threads to work simultaneously without the overhead of creating new connections for each thread.

```ruby
# Connection pooling is automatically used in batch operations
bucket.objects.download_batch(keys: large_list_of_keys, concurrency: 10)
```

### Thread-Safe Connection Management 🧵

S3::Light ensures thread-safe connection management, allowing you to use it safely in multi-threaded environments without worrying about race conditions or data corruption.

### Efficient Batch Processing 📦

Batch operations in S3::Light are designed to maximize throughput by processing multiple items concurrently while efficiently managing resources.

## Best Practices 🏆

To get the most out of S3::Light's performance features:

1. Reuse client instances when possible to take advantage of connection reuse.
2. Use batch operations for handling multiple items instead of processing them one by one.
3. Experiment with the `concurrency` parameter in batch operations to find the optimal setting for your use case and infrastructure.
4. Remember to call `S3Light::Client.close_all_connections` when your application is shutting down to properly release all resources.

## Development 🛠️

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing 🤝

Bug reports and pull requests are welcome on GitHub at https://github.com/sebyx07/s3-light. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/sebyx07/s3-light/blob/master/CODE_OF_CONDUCT.md).

## License 📄

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct 🤓

Everyone interacting in the S3::Light project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/sebyx07/s3-light/blob/master/CODE_OF_CONDUCT.md).