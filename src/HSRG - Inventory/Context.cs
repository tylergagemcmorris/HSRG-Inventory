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
        }

        public virtual DbSet<InventoryDetail> InventoryDetails { get; set; }
        public virtual DbSet<BIOSInformation> BIOSInformation { get; set; }
        public virtual DbSet<MemoryInformation> MemoryInformation { get; set; }
        public virtual DbSet<SystemInformation> SystemInformation { get; set; }

    }

}