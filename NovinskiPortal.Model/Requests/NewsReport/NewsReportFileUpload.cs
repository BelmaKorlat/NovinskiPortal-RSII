namespace NovinskiPortal.Model.Requests.NewsReport
{
    public class NewsReportFileUpload
    {
        public string FileName { get; set; } = default!;

        public string ContentType { get; set; } = default!;

        public byte[] Content { get; set; } = default!;
    }
}

