namespace NovinskiPortal.Model.Responses
{
    public class NewsReportFileResponse
    {
        public int Id { get; set; }

        public string OriginalFileName { get; set; } = default!;

        public string FilePath { get; set; } = default!;

        public string ContentType { get; set; } = default!;

        public long Size { get; set; }
    }
}
