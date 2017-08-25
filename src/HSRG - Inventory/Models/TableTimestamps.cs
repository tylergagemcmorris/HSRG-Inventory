using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Web;

namespace HSRG___Inventory.Models
{
    [Table("TableTimestamps")]
    public class TableTimestamps
    {
        [Key]
        public int ID { get; set; }
        public string InventoryDetail { get; set; }
        public string BiosInformation { get; set; }
        public string DriveSpace { get; set; }
        public string HardDiskInformation { get; set; }
        public string MemoryInformation { get; set; }
        public string MotherBoardInformation { get; set; }
        public string NetworkAdapters { get; set; }
        public string SystemEnclosure { get; set; }
        public string SystemInformation { get; set; }
        public string UpdatesInstalled { get; set; }
    }
}