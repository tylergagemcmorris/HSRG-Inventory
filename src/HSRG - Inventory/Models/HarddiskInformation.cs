using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace HSRG___Inventory.Models
{
    [Table("HardDiskInformation")]
    public class HardDiskInformation
    {
        [Key]
        public string ComputerID { get; set; }
        public string Model { get; set; }
        public string SerialNumber { get; set; }
        public string InterfaceType { get; set; }
        public string Size { get; set; }
        public string Partitions { get; set; }

    }
}