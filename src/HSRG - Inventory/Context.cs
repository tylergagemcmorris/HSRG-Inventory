using System;
using System.Data.Entity;
using System.Linq;
using HSRG___Inventory.Models;
using System.Web;
using System.Data.SQLite;
using SQLite.CodeFirst;

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
    }

}