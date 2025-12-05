using System.Text;
using System.Text.Json;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using NovinskiPortal.Common.Messaging;
using NovinskiPortal.Common.Settings;
using NovinskiPortal.Services.Services.ArticleService;
using RabbitMQ.Client;

namespace NovinskiPortal.Workers.Statistics
{
    public class ArticleViewedWorker : BackgroundService
    {
        private readonly ILogger<ArticleViewedWorker> _logger;
        private readonly RabbitMqSettings _settings;
        private readonly IServiceScopeFactory _scopeFactory;

        private IConnection? _connection;
        private IChannel? _channel;

        private const string QueueName = "article.viewed.queue";

        public ArticleViewedWorker(
            ILogger<ArticleViewedWorker> logger,
            IOptions<RabbitMqSettings> options,
            IServiceScopeFactory scopeFactory)
        {
            _logger = logger;
            _settings = options.Value;
            _scopeFactory = scopeFactory;
        }

        public override async Task StartAsync(CancellationToken cancellationToken)
        {
            var factory = new ConnectionFactory
            {
                HostName = _settings.HostName,
                Port = _settings.Port,
                UserName = _settings.UserName,
                Password = _settings.Password,
                ClientProvidedName = "novinskiportal-statistics-worker"
            };

            _connection = await factory.CreateConnectionAsync(cancellationToken);

            _channel = await _connection.CreateChannelAsync(
                options: null,
                cancellationToken: cancellationToken);

            await _channel.ExchangeDeclareAsync(
                exchange: _settings.Exchange,
                type: ExchangeType.Topic,
                durable: true,
                autoDelete: false,
                arguments: null,
                cancellationToken: cancellationToken);

            await _channel.QueueDeclareAsync(
                queue: QueueName,
                durable: true,
                exclusive: false,
                autoDelete: false,
                arguments: null,
                cancellationToken: cancellationToken);

            await _channel.QueueBindAsync(
                queue: QueueName,
                exchange: _settings.Exchange,
                routingKey: _settings.RoutingKeyArticleViewed,
                arguments: null,
                cancellationToken: cancellationToken);

            _logger.LogInformation("ArticleViewedWorker started");

            await base.StartAsync(cancellationToken);
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            if (_channel == null)
            {
                throw new InvalidOperationException("Channel is not initialized.");
            }

            while (!stoppingToken.IsCancellationRequested)
            {
                try
                {
                    var result = await _channel.BasicGetAsync(
                        queue: QueueName,
                        autoAck: false,
                        cancellationToken: stoppingToken);

                    if (result == null)
                    {
                        await Task.Delay(1000, stoppingToken);
                        continue;
                    }

                    var body = result.Body.ToArray();
                    var json = Encoding.UTF8.GetString(body);

                    var evt = JsonSerializer.Deserialize<ArticleViewedEvent>(json);

                    if (evt != null)
                    {
                        await HandleEventAsync(evt, stoppingToken);

                        await _channel.BasicAckAsync(
                            deliveryTag: result.DeliveryTag,
                            multiple: false,
                            cancellationToken: stoppingToken);
                    }
                    else
                    {
                        await _channel.BasicNackAsync(
                            deliveryTag: result.DeliveryTag,
                            multiple: false,
                            requeue: false,
                            cancellationToken: stoppingToken);
                    }
                }
                catch (OperationCanceledException)
                {
                    break;
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Greška prilikom obrade poruke u ArticleViewedWorker");
                    await Task.Delay(2000, stoppingToken);
                }
            }
        }

        private async Task HandleEventAsync(ArticleViewedEvent evt, CancellationToken ct)
        {
            using var scope = _scopeFactory.CreateScope();

            var articleService = scope.ServiceProvider
                .GetRequiredService<IArticleService>();

            await articleService.TrackViewAsync(evt.ArticleId, evt.UserId, evt.ViewedAtUtc, ct);

            _logger.LogInformation(
                "Obrađen view za article {ArticleId} u {Time}",
                evt.ArticleId,
                evt.ViewedAtUtc);
        }

        public override async Task StopAsync(CancellationToken cancellationToken)
        {
            _logger.LogInformation("ArticleViewedWorker stopping");

            if (_channel != null)
            {
                await _channel.CloseAsync(cancellationToken);
            }

            if (_connection != null)
            {
                await _connection.CloseAsync(cancellationToken);
            }

            await base.StopAsync(cancellationToken);
        }

        public override void Dispose()
        {
            _channel?.Dispose();
            _connection?.Dispose();
            base.Dispose();
        }
    }
}
