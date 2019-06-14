using System;
using System.IO;
using System.IO.Compression;

namespace Publisher
{
    internal class Program
    {
        private static void Main()
        {
            Publish("beep");

            Publish("beepServer");
        }

        private static void Publish(string dir)
        {
            Console.WriteLine($"Packing {dir}\n");
            foreach (string pathDirectory in Directory.EnumerateDirectories($"../../../../{dir}"))
            {
                string name = Path.GetFileName(pathDirectory);

                if (!name.StartsWith("application")) continue;

                string zipPath = Path.Join(Path.GetDirectoryName(pathDirectory),
                    "../release",
                    dir + name.Substring(11));
                Directory.CreateDirectory(Path.GetDirectoryName(zipPath));

                if (File.Exists($"{zipPath}.zip"))
                {
                    Console.WriteLine($" Detected old {zipPath}.zip...");
                    Console.WriteLine($" Deleting old {zipPath}.zip...");
                    File.Delete($"{zipPath}.zip");
                    Console.WriteLine($" Successfully deleted old {zipPath}.zip");
                }

                Console.WriteLine($" Zipping {zipPath}.zip...");
                ZipFile.CreateFromDirectory(pathDirectory, $"{zipPath}.zip");
                Console.WriteLine($" Successfully zipped {zipPath}.zip\n");
            }
            Console.WriteLine($"Successfully packed {dir}\n\n");
        }
    }
}
