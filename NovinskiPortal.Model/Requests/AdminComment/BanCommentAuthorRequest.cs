namespace NovinskiPortal.Model.Requests.AdminComment
{
    public class BanCommentAuthorRequest
    {
        public DateTime BanUntil { get; set; }
        public string? Reason { get; set; }
    }
}
