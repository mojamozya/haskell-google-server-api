{-# LANGUAGE TemplateHaskell #-}

{- |
Module      :  Google.Response

Define data types to represent all of the responses that are received from the Google API.
-}
module Google.Response
  ( Token(..)
  , Account(..)
  , DateTime(..)
  , ZonedDateTime(..)
  , CalendarEvent(..)
  , CalendarEventList(..)
  , GmailSend(..)
  , GmailList(..)
  , GmailMessage(..)
  , FileResource(..)
  , FileList(..)
  , MediaContent(..)
  ) where

import Data.Aeson.Casing (snakeCase)
import Data.Aeson.TH (Options(..), defaultOptions, deriveJSON)
import Data.Text (Text)
import Data.Text (intercalate, splitOn)
import Data.Typeable (Typeable)
import GHC.Generics (Generic)
import Web.FormUrlEncoded (FromForm, ToForm)
import Data.Time.Clock (UTCTime)
import Data.Time.LocalTime (ZonedTime, zonedTimeToUTC)
import Web.HttpApiData (FromHttpApiData(..), ToHttpApiData(..), parseUrlPieces, toUrlPieces)

import Google.Type (FileId, MediaType, MediaContent(..))


data Token = Token
  { accessToken :: Text
  , tokenType :: Text
  , expiresIn :: Int
  } deriving (Eq, Generic, Show, Typeable)

deriveJSON (defaultOptions {fieldLabelModifier = snakeCase}) ''Token

instance FromForm Token

instance ToForm Token

newtype Account = Account
  { email :: Text
  } deriving (Eq, Generic, Show, Typeable, FromHttpApiData, ToHttpApiData)

deriveJSON defaultOptions ''Account

instance FromHttpApiData [Account] where
  parseUrlPiece = parseUrlPieces . (splitOn ",")

instance ToHttpApiData [Account] where
  toUrlPiece = (intercalate ",") . toUrlPieces


newtype DateTime = DateTime
  { dateTime :: UTCTime
  } deriving (Eq, Generic, Show, Typeable, FromHttpApiData, ToHttpApiData)

deriveJSON defaultOptions ''DateTime


newtype ZonedDateTime = ZonedDateTime
  { dateTime :: Maybe ZonedTime
  } deriving (Generic, Show, Typeable, FromHttpApiData, ToHttpApiData)

deriveJSON defaultOptions ''ZonedDateTime

instance Eq ZonedDateTime where
  (==) =
    (\x y ->
      let
        toUTC :: ZonedDateTime -> Maybe UTCTime
        toUTC = (fmap zonedTimeToUTC) . (dateTime :: ZonedDateTime -> Maybe ZonedTime)
      in
        (toUTC x) == (toUTC y)
    )

data CalendarEvent = CalendarEvent
  { status :: Text
  , creator :: Account
  , attendees :: Maybe [Account]
  , summary :: Maybe Text
  , description :: Maybe Text
  , start :: Maybe ZonedDateTime
  , end :: Maybe ZonedDateTime
  } deriving (Eq, Generic, Show, Typeable)

deriveJSON defaultOptions ''CalendarEvent

instance FromForm CalendarEvent

instance ToForm CalendarEvent


data CalendarEventList = CalendarEventList
  { kind :: Text
  , summary :: Text
  , items :: [CalendarEvent]
  } deriving (Eq, Generic, Show, Typeable)

deriveJSON defaultOptions ''CalendarEventList


data GmailSend = GmailSend
  { id :: Text
  } deriving (Eq, Generic, Show, Typeable)

deriveJSON defaultOptions ''GmailSend

instance FromForm GmailSend

instance ToForm GmailSend

data GmailMessage = GmailMessage
  { id :: Text
  , threadId :: Text
  , snippet :: Maybe Text
  } deriving (Eq, Generic, Show, Typeable)
deriveJSON defaultOptions ''GmailMessage

instance FromForm GmailMessage

instance ToForm GmailMessage

data GmailList = GmailList
  { messages :: [GmailMessage]
  } deriving (Eq, Generic, Show, Typeable)
deriveJSON defaultOptions ''GmailList

data FileResource = FileResource
  { kind :: Text
  , id :: FileId
  , name :: Text
  , mimeType :: MediaType
  } deriving (Eq, Generic, Show, Typeable)

deriveJSON defaultOptions ''FileResource


data FileList = FileList
  { kind :: Text
  , files :: [FileResource]
  } deriving (Eq, Generic, Show, Typeable)

deriveJSON defaultOptions ''FileList
