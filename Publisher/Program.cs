using System;
using System.IO;
using System.IO.Compression;

namespace Publisher
{
    class Program
    {
        static void Main(string[] args)
        {
            Publish("beep");
            Publish("beepServer");
        }

        static void Publish(string dir)
        {
            foreach (var pathDirectory in Directory.EnumerateDirectories("../../../../" + dir))
            {
                var name = Path.GetFileName(pathDirectory);
                if (name.StartsWith("application"))
                {
                    var zipPath = Path.Join(Path.GetDirectoryName(pathDirectory),
                        "../release",
                        dir + name.Substring(11));
                    Directory.CreateDirectory(zipPath);
                    File.Delete(zipPath + ".zip");
                    ZipFile.CreateFromDirectory(pathDirectory, zipPath+".zip");
                }
            }
        }
    }
}
