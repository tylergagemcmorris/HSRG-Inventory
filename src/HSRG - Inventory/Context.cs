using System;
using System.Data.Entity;
using System.Linq;
using HSRG___Inventory.Models;
using System.Web;
using System.Data.SQLite;
using SQLite.CodeFirst;

//more test stuff
//this is a test comment
namespace HSRG___Inventory
{
    public class Context : DbContext
    {
        public Context(string connString)
            : base(connString){ }

        protected override void OnModelCreating(DbModelBuilder modelBuilder)
        {
            var sqliteConnectionInitializer = new SqliteCreateDatabaseIfNotExists<Context>(modelBuilder);
            Database.SetInitializer(sqliteConnectionInitializer);

            modelBuilder.Entity<DriveSpace>().HasKey(t => new { t.ComputerID, t.DriveLetter });
            modelBuilder.Entity<MemoryInformation>().HasKey(t => new { t.ComputerID, t.BankLabel });
            modelBuilder.Entity<NetworkAdapters>().HasKey(t => new { t.ComputerID, t.Name });
            modelBuilder.Entity<UpdatesInstalled>().HasKey(t => new { t.ComputerID, t.HotFixID });
        }

        public virtual DbSet<InventoryDetail> InventoryDetails { get; set; }
        public virtual DbSet<BIOSInformation> BIOSInformation { get; set; }
        public virtual DbSet<MemoryInformation> MemoryInformation { get; set; }
        public virtual DbSet<DriveSpace> DriveSpace { get; set; }
        public virtual DbSet<HardDiskInformation> HardDiskInformation { get; set; }
        public virtual DbSet<MotherBoardInformation> MotherBoardInformation { get; set; }
        public virtual DbSet<NetworkAdapters> NetworkAdapters { get; set; }
        public virtual DbSet<SystemEnclosure> SystemEnclosure { get; set; }
        public virtual DbSet<SystemInformation> SystemInformation { get; set; }
        public virtual DbSet<UpdatesInstalled> UpdatesInstalled { get; set; }

    }

}