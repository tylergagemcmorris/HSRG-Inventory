using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace HSRG___Inventory.Models
{
    [Table("MotherBoardInformation")]
    public class MotherBoardInformation
    {
        [Key]
        public string ComputerID { get; set; }
        public string Name { get; set; }
        public string Manufacturer { get; set; }
        public string Product { get; set; }
        [Column("Serial Number")]
        public string SerialNumber { get; set; }
        public string Status { get; set; }

    }
}