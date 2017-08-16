using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace HSRG___Inventory.Models
{
    [Table("InventoryDetail")]
    public class InventoryDetail
    {
        [Key]
        public string ComputerID { get; set; }
        public string Model { get; set; }
        [Column("CPU Info")]
        public string CPUInfo { get; set; }
        public string OS { get; set; }
        [Column("Serial Number")]
        public string SerialNumber { get; set; }
        [Column("IP Address")]
        public string IPAddress { get; set; }
        [Column("MAC Address")]
        public string MACAddress { get; set; }
        [Column("Drive Space - GB")]
        public string DriveSpace { get; set; }
        [Column("Total Physical Memory")]
        public decimal TotalPhysicalMemory { get; set; }
        [Column("Last Reboot")]
        public DateTime LastReboot { get; set; }
    }
        
}