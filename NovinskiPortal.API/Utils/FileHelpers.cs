using NovinskiPortal.Model.Requests.Article;

namespace NovinskiPortal.API.Utils
{
    public class FileHelpers
    {
        public static async Task<PhotoUpload> ToPhotoUploadAsync(IFormFile file)
        {
            using var memoryStream = new MemoryStream();
            await file.CopyToAsync(memoryStream);
            return new PhotoUpload
            {
                FileName = file.FileName,
                Content = memoryStream.ToArray()
            };
        }

        public static async Task<List<PhotoUpload>> ToPhotoUploadsAsync(List<IFormFile>? files)
        {
            var list = new List<PhotoUpload>();
            if (files == null)
                return list;
            foreach (var item in files)
            {
                list.Add(await ToPhotoUploadAsync(item));
            }
            return list;
        }

   

    }
}
