using System;
using System.Reflection;

namespace $rootnamespace$
{
    class Program
    {
        private static string Provider = MigrationSettings.Default.Provider;

        private static string ConnectionString = string.Empty;

        private static bool DryRun = false;

        private static bool IsVersionSpecified = false;

        private static long Version = 0;

        private static bool Pause = false;

        static void Main(string[] args)
        {
            ProcessArguments(args);

            if (string.IsNullOrWhiteSpace(ConnectionString))
            {
                throw new ArgumentNullException("No valid configuration provided (use /configuration:...)");
            }

            var migrator = new Migrator.Migrator(Provider, ConnectionString, typeof(Program).Assembly);

            migrator.DryRun = DryRun;

            if (IsVersionSpecified)
            {
                migrator.MigrateTo(Version);
            }
            else
            {
                migrator.MigrateToLastVersion();
            }

            if (Pause)
            {
                Console.WriteLine("Press any key to continue...");
                Console.ReadKey();
            }
        }

        private static void ProcessArguments(string[] args)
        {
            foreach (var argument in args)
            {
                if (argument.StartsWith("/version:") || argument.StartsWith("/v:"))
                {
                    IsVersionSpecified = true;

                    Version = long.Parse(argument.Split(':')[1]);
                }
                else if (argument.Equals("/dryrun") || argument.Equals("/d"))
                {
                    DryRun = true;
                }
                else if (argument.StartsWith("/configuration:") || argument.StartsWith("/c:"))
                {
                    var configuration = argument.Split(':')[1];

                    try
                    {
                        var connectionString = (string)MigrationSettings.Default[configuration.ToUpper()];

                        ConnectionString = connectionString;
                    }
                    catch (Exception)
                    {
                        throw new ArgumentOutOfRangeException("\"" + configuration + "\" is not a valid configuration");
                    }
                }
                else if (argument.StartsWith("/connectionString:"))
                {
                    ConnectionString = argument.Split(':')[1];
                }
                else if (argument.Equals("/pause") || argument.Equals("/p"))
                {
                    Pause = true;
                }
                else if (argument.StartsWith("/target:") || argument.StartsWith("/t:"))
                {
                    var provider = argument.Split(':')[1];

                    Provider = provider;
                }
            }
        }
    }
}
