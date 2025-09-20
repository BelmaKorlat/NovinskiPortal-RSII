

namespace NovinskiPortal.Model.Constants
{
    public class RoleConstants
    {
        public const int Admin = 1;
        public const int User = 2;

        // korisno za [Authorize(Roles="1")]
        public const string AdminString = "1";
        public const string UserString = "2";
    }
}
