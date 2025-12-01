namespace NovinskiPortal.Common.Messaging
{
    public class ArticleViewedEvent
    {
        public int ArticleId { get; set; }
        public int? UserId { get; set; }
        public DateTime ViewedAtUtc { get; set; }
    }
}
